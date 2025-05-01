using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Comp375BackEnd.Models
{
    [Table("Movie")]
    public class MovieModel
    {
        [Key]
        public long MovieId { get; set; }
        public string? Description { get; set; }
        public string? PostedUrl { get; set; }
        public string? Title { get; set; }
        [ForeignKey("Genre")]
        public long GenreId { get; set; }
    }
}
