using System.ComponentModel.DataAnnotations.Schema;

namespace Backend.Models
{
    public class Player
    {
        public int Id { get; set; }
        public string username { get; set; } = string.Empty;
        public string password { get; set; } = string.Empty;

        // jumlah coin yang sedang dimiliki 
        public int coins { get; set; } = 0;

        // total waktu bermain
        public int TimePlayed { get; set; } = 0;

        // waktu terakhir main
        public DateTime? LastPlayed { get; set; }

        // koleksi item
        public List<int> ItemCollection { get; set; } = new List<int>();

        // properti tambahan untuk tampilan stopwatch
        [NotMapped]
        public string FormattedTime =>
            TimeSpan.FromSeconds(TimePlayed).ToString(@"hh\:mm\:ss");
    }
}