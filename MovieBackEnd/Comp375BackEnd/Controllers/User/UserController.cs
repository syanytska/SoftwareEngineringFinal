using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Comp375BackEnd.Data;
using Comp375BackEnd.Models;

namespace Comp375BackEnd.Controllers.User
{
    [ApiController]
    [Route("[controller]")]
    public class UserController : ControllerBase
    {
        private readonly ILogger<UserController> _logger;
        private readonly MyContext _context;

        public UserController(MyContext context, ILogger<UserController> logger)
        {
            _logger = logger;
            _context = context;
        }

        [HttpGet("[action]")]
        public IActionResult GetUsers()
        {
            try
            {
                var users = _context.User.ToList();
                return Ok(users);
            }
            catch (Exception e)
            {
                _logger.LogError("Error message: " + e.Message);
                _logger.LogError("Stack trace: " + e.StackTrace);
                return BadRequest();
            }
        }

        [HttpGet("[action]")]
        public IActionResult GetUserById(long id)
        {
            try
            {
                var item = _context.User.Find(id);

                if (item == null)
                {
                    _logger.LogWarning($"Id not found: {id}");
                    return NotFound();
                }

                return Ok(item);
            }
            catch (Exception e)
            {
                _logger.LogError("Error message: " + e.Message);
                _logger.LogError("Stack trace: " + e.StackTrace);
                return BadRequest();
            }
        }

        [HttpPost("[action]")]
        public IActionResult CreateUser([FromBody] UserModel user)
        {
            try
            {
                if (user == null)
                    return BadRequest("Invalid user data");

                var existingUser = _context.User.FirstOrDefault(u => u.Username == user.Username);
                if (existingUser != null)
                    return Conflict("User already exists");

                _context.User.Add(user);
                _context.SaveChanges();

                return CreatedAtAction(nameof(GetUsers), new { id = user.UserId }, user);
            }
            catch (Exception e)
            {
                _logger.LogError("error: " + e.Message);
                return BadRequest("Failed to create user");
            }
        }

        [HttpPut("[action]")]
        public IActionResult UpdateUser(long id, [FromBody] UserModel model)
        {
            try
            {
                if (id != model.UserId)
                {
                    _logger.LogWarning("Id mismatch");
                    return BadRequest();
                }

                var user = _context.User.Find(id);
                if (user == null)
                {
                    _logger.LogWarning($"Id not found: {id}");
                    return NotFound();
                }

                user.Username = model.Username;
                user.PasswordHash = model.PasswordHash;
                user.Email = model.Email;
                user.PhoneNumber = model.PhoneNumber;

                _context.SaveChanges();

                return NoContent();
            }
            catch (Exception e)
            {
                _logger.LogError("Error message: " + e.Message);
                _logger.LogError("Stack trace: " + e.StackTrace);
                return BadRequest();
            }
        }

        [HttpDelete("[action]")]
        public IActionResult DeleteUser(long id)
        {
            try
            {
                var user = _context.User.Find(id);
                if (user == null)
                {
                    _logger.LogWarning($"Id not found: {id}");
                    return NotFound();
                }

                _context.User.Remove(user);
                _context.SaveChanges();

                return NoContent();
            }
            catch (Exception e)
            {
                _logger.LogError("Error message: " + e.Message);
                _logger.LogError("Stack trace: " + e.StackTrace);
                return BadRequest();
            }
        }

        [Authorize]
        [HttpGet("hello")]
        public IActionResult SayHello()
        {
            return Ok("Hello from a protected backend route!");
        }
    }
}
