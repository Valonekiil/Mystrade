using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json;

namespace Backend.Models
{
    public class Player
    {
        public int Id { get; set; }
        public string username { get; set; } = string.Empty;
        public string password { get; set; } = string.Empty;
        public int coins { get; set; } = 0;
        public int TimePlayed { get; set; } = 0;
        public DateTime? LastPlayed { get; set; }

        public string ItemCollectionData { get; set; } = "[]";

        [NotMapped]
        public List<int> ItemCollection
        {
            get
            {
                if (string.IsNullOrEmpty(ItemCollectionData))
                    return new List<int>();
                return JsonSerializer.Deserialize<List<int>>(ItemCollectionData) ?? new List<int>();
            }
            set
            {
                ItemCollectionData = JsonSerializer.Serialize(value ?? new List<int>());
            }
        }

        public int last_cus { get; set; } = 0;
        public int last_item { get; set; } = 0;

        [NotMapped]
        public string FormattedTime =>
            TimeSpan.FromSeconds(TimePlayed).ToString(@"hh\:mm\:ss");
    }
}
