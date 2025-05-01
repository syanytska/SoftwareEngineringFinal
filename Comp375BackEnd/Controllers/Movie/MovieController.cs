using Comp375BackEnd.Data;
using Comp375BackEnd.Models;
using Microsoft.AspNetCore.Mvc;

namespace Comp375BackEnd.Controllers.Movie
{
    [ApiController]
    [Route("[controller]")]
    public class MovieController : ControllerBase
    {
        private readonly ILogger<MovieController> _logger;
        private readonly MyContext _context;
        public MovieController(MyContext context, ILogger<MovieController> logger)
        {
            // Constructor logic here
            _logger = logger;
            _context = context;
        }
        [HttpGet("[action]")]
        public IActionResult GetMovies()
        {
            // Logic to get movies
            try
            {
                var movies = _context.Movie.ToList(); // to the list of objects in the db
                return Ok(movies);
            }
            catch (Exception e)
            {
                _logger.LogError("Error message: " + e.Message); // log the error message
                _logger.LogError("Stack trace: " + e.StackTrace); // log the stack trace
                return BadRequest();
            }
        }

        [HttpGet("[action]")]
        public async Task<IActionResult> GetMoviesById(long id)
        {
            try
            {
                var item = await _context.Movie.FindAsync(id); // finds the item async

                if (item == null) // if the item isn't found -> return 404
                {
                    _logger.LogWarning($"Id not found: {id}");
                    return NotFound(); // 404
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
        public async Task<IActionResult> CreateMovie([FromBody] MovieModel movie)
        {
            try
            {
                if (movie == null) // if the movie is null -> return 400
                {
                    _logger.LogWarning("Movie is null");
                    return BadRequest();
                }

                await _context.Movie.AddAsync(movie); // add the movie to the db
                await _context.SaveChangesAsync(); // save the changes to the db
                return CreatedAtAction(nameof(GetMoviesById), new { id = movie.MovieId }, movie); // return 201
            }
            catch (Exception e)
            {
                _logger.LogError("Error message: " + e.Message);
                _logger.LogError("Stack trace: " + e.StackTrace);
                return BadRequest();
            }
        }

        [HttpPut("[action]")]
        public async Task<IActionResult> UpdateMovie(long id, [FromBody] MovieModel movie)
        {
            try
            {
                if (id != movie.MovieId) // if the id doesn't match the movie id -> return 400
                {
                    _logger.LogWarning("Id mismatch");
                    return BadRequest();
                }
                var item = await _context.Movie.FindAsync(id); // find the item async
                if (item == null) // if the item isn't found -> return 404
                {
                    _logger.LogWarning($"Id not found: {id}");
                    return NotFound();
                }
                item.Description = movie.Description; // update the item
                item.PostedUrl = movie.PostedUrl;
                item.Title = movie.Title;
                item.GenreId = movie.GenreId;
                await _context.SaveChangesAsync(); // save the changes to the db
                return NoContent(); // return 204
            }
            catch (Exception e)
            {
                _logger.LogError("Error message: " + e.Message);
                _logger.LogError("Stack trace: " + e.StackTrace);
                return BadRequest();
            }
        }
        [HttpDelete("[action]")]
        public async Task<IActionResult> DeleteMovie(long id)
        {
            try
            {
                var item = await _context.Movie.FindAsync(id); // find the item async
                if (item == null) // if the item isn't found -> return 404
                {
                    _logger.LogWarning($"Id not found: {id}");
                    return NotFound();
                }
                _context.Movie.Remove(item); // remove the item from the db
                await _context.SaveChangesAsync(); // save the changes to the db
                return NoContent(); // return 204
            }
            catch (Exception e)
            {
                _logger.LogError("Error message: " + e.Message);
                _logger.LogError("Stack trace: " + e.StackTrace);
                return BadRequest();
            }
        }
    }
}
