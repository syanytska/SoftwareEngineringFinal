using Comp375BackEnd.Data;
using Comp375BackEnd.Models;
using Comp375BackEnd.Models.Auth;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace Comp375BackEnd.Controllers.Auth
{
    [ApiController]
    [Route("[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IConfiguration _configuration; // to access JWT secret key etc.
        private readonly MyContext _context; // database context
        private readonly IPasswordHasher<UserModel> _passwordHasher; // for securely hashing passwords

        public AuthController(IConfiguration configuration, MyContext context, IPasswordHasher<UserModel> passwordHasher)
        {
            _configuration = configuration;
            _context = context;
            _passwordHasher = passwordHasher;
        }

        // ---------------- LOGIN ENDPOINT ----------------
        [HttpPost("login")]
        public IActionResult Login([FromBody] LoginRequest request)
        {
            // Check for missing username or password
            if (string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password))
                return BadRequest("Username and password are required");

            // Try to find the user in the database
            var user = _context.User.FirstOrDefault(u => u.Username == request.Username);
            if (user == null)
                return Unauthorized("Invalid credentials");

            // Verify that the password is correct
            var result = _passwordHasher.VerifyHashedPassword(user, user.PasswordHash, request.Password);
            if (result == PasswordVerificationResult.Failed)
                return Unauthorized("Invalid credentials");

            // Get role name from Role table
            var roleName = _context.Role.FirstOrDefault(r => r.RoleId == user.RoleId)?.Name ?? "Guest";

            // Create claims to include in the JWT
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.Name, user.Username),
                new Claim(ClaimTypes.Role, roleName),
                new Claim("UserId", user.UserId.ToString())
            };

            // Create a JWT key and sign it
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]!));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            // Create the JWT token
            var token = new JwtSecurityToken(
                issuer: _configuration["Jwt:Issuer"],
                audience: _configuration["Jwt:Audience"],
                claims: claims,
                expires: DateTime.Now.AddHours(1),
                signingCredentials: creds);

            // Return token + user info to the frontend
            return Ok(new
            {
                token = new JwtSecurityTokenHandler().WriteToken(token),
                user = new { user.UserId, user.Username, Role = roleName }
            });
        }

        // ---------------- REGISTER ENDPOINT ----------------
        [HttpPost("register")]
        public IActionResult Register([FromBody] RegisterRequest model)
        {
            // Check for empty fields
            if (string.IsNullOrWhiteSpace(model.Username) || string.IsNullOrWhiteSpace(model.Password) || string.IsNullOrWhiteSpace(model.Role))
                return BadRequest("All fields are required");

            // Check if username already exists
            if (_context.User.Any(u => u.Username == model.Username))
                return BadRequest("Username already exists");

            // Find the matching role in the Role table
            var role = _context.Role.FirstOrDefault(r => r.Name == model.Role);
            if (role == null)
                return BadRequest("Invalid role");

            // Create new user with hashed password and role
            var user = new UserModel
            {
                Username = model.Username,
                PasswordHash = _passwordHasher.HashPassword(null, model.Password),
                RoleId = role.RoleId
            };

            // Save the new user to the database
            _context.User.Add(user);
            _context.SaveChanges();

            // Create claims just like in login
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.Name, user.Username),
                new Claim(ClaimTypes.Role, role.Name),
                new Claim("UserId", user.UserId.ToString())
            };

            // Build the JWT token
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]!));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: _configuration["Jwt:Issuer"],
                audience: _configuration["Jwt:Audience"],
                claims: claims,
                expires: DateTime.Now.AddHours(1),
                signingCredentials: creds);

            // Return the token and user info so frontend can immediately log in
            return Ok(new
            {
                token = new JwtSecurityTokenHandler().WriteToken(token),
                user = new { user.UserId, user.Username, Role = role.Name }
            });
        }
    }
}
