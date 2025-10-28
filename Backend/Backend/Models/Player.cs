namespace Backend.Models
{
    public class Player
    {
        public int Id { get; set; }
        public string username { get; set; } = string.Empty;
        public string password { get; set; } = string.Empty;
        public int item { get; set; } = 0;
    }
}
