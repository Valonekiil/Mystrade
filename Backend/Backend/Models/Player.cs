using System.ComponentModel.DataAnnotations.Schema;

namespace Backend.Models
{
    public class Player
    {
        public int Id { get; set; }
        public string username { get; set; } = string.Empty;
        public string password { get; set; } = string.Empty;

        // jumlah item yang sedang dimiliki (bisa buat urutan leaderboard)
        public int item { get; set; } = 0;

        // total waktu bermain (dalam detik)
        public int TimePlayed { get; set; } = 0;

        // waktu terakhir main
        public DateTime? LastPlayed { get; set; }

        // koleksi item (misal ID item yang sudah dikoleksi)
        public List<int> ItemCollection { get; set; } = new List<int>();

        // properti tambahan (tidak tersimpan di database) untuk tampilan stopwatch
        [NotMapped]
        public string FormattedTime =>
            TimeSpan.FromSeconds(TimePlayed).ToString(@"hh\:mm\:ss");
    }
}