using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Comp375BackEnd.Models
{
    [Table("Genre")]
    public class GenreModel
    {
        [Key]
        public long GenreId { get; set; }
        public string Name { get; set; }
        public ICollection<MovieModel> Movies { get; set; }
    }
}
