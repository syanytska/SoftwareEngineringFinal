using Comp375BackEnd.Data;
using Comp375BackEnd.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Comp375BackEnd.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class GenreController : ControllerBase
    {
        private readonly MyContext _context;
        private readonly ILogger<GenreController> _logger;

        public GenreController(MyContext context, ILogger<GenreController> logger)
        {
            _context = context;
            _logger = logger;
        }

        [HttpGet("[action]")]
        public async Task<IActionResult> GetGenres()
        {
            try
            {
                var genres = await _context.Genre.ToListAsync();
                return Ok(genres);
            }
            catch (Exception e)
            {
                _logger.LogError("GenreController.GetGenres error: " + e.Message);
                return BadRequest("Could not fetch genres");
            }
        }

        [HttpPost("[action]")]
        public async Task<IActionResult> CreateGenre([FromBody] GenreModel genre)
        {
            try
            {
                if (genre == null)
                    return BadRequest("Invalid genre data");

                var existingGenre = await _context.Genre.FirstOrDefaultAsync(g => g.Name == genre.Name); // finds the genre by name

                if (existingGenre != null)
                    return Conflict("Genre already exists");

                // else
                _context.Genre.Add(genre);
                await _context.SaveChangesAsync(); // save changes 

                return CreatedAtAction(nameof(GetGenres), new { id = genre.GenreId }, genre);
            }
            catch (Exception e)
            {
                _logger.LogError("error: " + e.Message);
                return BadRequest("Failed to create genre");
            }
        }

        [HttpDelete("[action]")]
        public async Task<IActionResult> DeleteGenre(long id)
        {
            try
            {
                var genre = await _context.Genre.FindAsync(id); // finds the genre by id

                if (genre == null)
                    return NotFound("Genre not found");

                // else
                _context.Genre.Remove(genre);
                await _context.SaveChangesAsync(); // save changes

                return Ok("Genre deleted successfully");
            }
            catch (Exception e)
            {
                _logger.LogError("GenreController.DeleteGenre error: " + e.Message);
                return BadRequest("Failed to delete genre");
            }
        }
    }
}
