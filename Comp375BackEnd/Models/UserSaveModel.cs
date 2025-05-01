using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Comp375BackEnd.Models
{
    [Table("UserSave")]
    public class UserSaveModel
    {
        [Key]
        public long UserSaveId { get; set; }
        [ForeignKey("User")]
        public long UserId { get; set; }
        [ForeignKey("Movie")]
        public long MovieId { get; set; }
    }
}
