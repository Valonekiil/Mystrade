using Microsoft.EntityFrameworkCore;
using Backend.Models;
using System.Text.Json;
using System.ComponentModel.DataAnnotations.Schema;

namespace Backend.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options)
            : base(options)
        {
        }

        public DbSet<Player> Players { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Simpan List<int> ItemCollection sebagai JSON string di SQLite
            modelBuilder.Entity<Player>()
                .Property(p => p.ItemCollection)
                .HasConversion(
                    v => JsonSerializer.Serialize(v ?? new List<int>(), (JsonSerializerOptions)null),
                    v => string.IsNullOrEmpty(v)
                        ? new List<int>()
                        : JsonSerializer.Deserialize<List<int>>(v, (JsonSerializerOptions)null)
                );
        }
    }
}
