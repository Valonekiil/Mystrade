using Backend.Data;
using Backend.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Backend.Controllers
{
    [ApiController]
    [Route("Players")]
    public class PlayersController : ControllerBase
    {
        private readonly AppDbContext _context;

        public PlayersController(AppDbContext context)
        {
            _context = context;
        }

        // GET semua player
        [HttpGet]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<ActionResult<IEnumerable<Player>>> GetPlayers()
        {
            var players = await _context.Players
                .OrderByDescending(p => p.coins)
                .ToListAsync();

            return Ok(players);
        }

        // GET player berdasarkan ID
        [HttpGet("{id}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<Player>> GetPlayer(int id)
        {
            var player = await _context.Players.FindAsync(id);
            if (player == null)
                return NotFound();

            return Ok(player);
        }

        [HttpPost]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<ActionResult<Player>> AddPlayer([FromBody] RegisterRequest request)
        {
            if (request == null)
                return BadRequest("Body tidak boleh kosong.");

            if (string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password))
                return BadRequest("Username dan password wajib diisi.");

            //eror handling username
            var existingPlayer = await _context.Players
                .FirstOrDefaultAsync(p => p.username == request.Username);

            if (existingPlayer != null)
            {
                return Conflict(new { message = "Username sudah terdaftar!" });
            }

            var player = new Player
            {
                username = request.Username,
                password = request.Password,
                coins = 1000,
                TimePlayed = 0,
                LastPlayed = DateTime.UtcNow,
                ItemCollection = new List<int>(),
                last_cus = 0,
                last_item = 0
            };


            _context.Players.Add(player);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetPlayer), new { id = player.Id }, player);
        }

        // apdet data player
        [HttpPut("{id}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> UpdatePlayer(int id, [FromBody] UpdateRequest request)
        {
            var player = await _context.Players.FindAsync(id);
            if (player == null)
                return NotFound();

            if (request != null)
            {
                player.username = request.Username ?? player.username;
                player.password = request.Password ?? player.password;
                player.coins = request.Coins;                  
                player.TimePlayed = request.TimePlayed;       
                player.last_cus = request.lastCus;               
                player.last_item = request.lastItem;             
                player.ItemCollection = request.ItemCollection;  
            }

            await _context.SaveChangesAsync();
            return Ok(player);
        }

        // PATCH coins 
        [HttpPatch("{id}/coins")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<Player>> UpdatePlayerCoins(int id, [FromBody] UpdateCoinRequest request)
        {
            if (request == null)
                return BadRequest("Body tidak boleh kosong.");

            var player = await _context.Players.FindAsync(id);
            if (player == null)
                return NotFound();

            player.coins = request.Coins;
            await _context.SaveChangesAsync();

            return Ok(player);
        }

        [HttpPatch("{id}/items/add")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> AddItem(int id, [FromBody] AddItemRequest request)
        {
            if (request == null)
                return BadRequest("Body tidak boleh kosong.");

            var player = await _context.Players.FindAsync(id);
            if (player == null)
                return NotFound();

            var items = player.ItemCollection;          // baca (deserialize) aman
            if (!items.Contains(request.NewItem))
            {
                items.Add(request.NewItem);
                player.ItemCollection = items;          // assign kembali biar setter serializes
                await _context.SaveChangesAsync();
            }

            return Ok(player.ItemCollection);
        }


        // Start game
        [HttpPost("{id}/start-game")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<IActionResult> StartGame(int id)
        {
            var player = await _context.Players.FindAsync(id);
            if (player == null)
                return NotFound();

            player.LastPlayed = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new
            {
                Message = $"Player {player.username} started playing.",
                player.LastPlayed
            });
        }

        // End game
        [HttpPost("{id}/end-game")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<IActionResult> EndGame(int id)
        {
            var player = await _context.Players.FindAsync(id);
            if (player == null)
                return NotFound();

            if (player.LastPlayed == null)
                return BadRequest("Game was not started properly.");

            var duration = (DateTime.UtcNow - player.LastPlayed.Value).TotalSeconds;
            player.TimePlayed += (int)duration;
            player.LastPlayed = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return Ok(new
            {
                Message = $"Game ended. Session duration: {duration} seconds",
                TotalTimePlayed = player.FormattedTime
            });
        }

        // login
        [HttpPost("login")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<ActionResult<object>> Login([FromBody] LoginRequest request)  // ← GANTI KE object
        {
            if (request == null)
                return BadRequest("Body tidak boleh kosong.");

            if (string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password))
                return BadRequest("Username dan password wajib diisi.");

            var player = await _context.Players
                .FirstOrDefaultAsync(p => p.username == request.Username && p.password == request.Password);

            if (player == null)
                return Unauthorized("Username atau password salah.");

            // ⬇️ CONVERT KE ANONYMOUS OBJECT EXPLICIT ⬇️
            return Ok(new
            {
                id = player.Id,
                username = player.username,
                password = player.password,
                coins = player.coins,
                timePlayed = player.TimePlayed,
                itemCollection = player.ItemCollection
            });
        }

        // leaderboard: Berdasarkan jumlah total item di koleksi
        [HttpGet("leaderboard")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<ActionResult<IEnumerable<object>>> GetLeaderboard()
        {
            var players = await _context.Players
                .ToListAsync();

            var leaderboard = players
                .OrderByDescending(p => p.ItemCollection.Count) // urut berdasarkan jumlah item
                .ThenByDescending(p => p.coins)
                .Select((p, index) => new
                {
                    Rank = index + 1,
                    p.username,
                    TotalItems = p.ItemCollection.Count,
                    Coins = p.coins,
                    TimePlayed = TimeSpan.FromSeconds(p.TimePlayed).ToString(@"hh\:mm\:ss")
                });

            return Ok(leaderboard);
        }

        // DELETE: Players/{id}
        [HttpDelete("{id}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> DeletePlayer(int id)
        {
            var player = await _context.Players.FindAsync(id);
            if (player == null)
                return NotFound(new { Message = $"Player dengan ID {id} tidak ditemukan." });

            _context.Players.Remove(player);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                Message = $"Player {player.username} berhasil dihapus.",
                DeletedId = id
            });
        }

        // === 1️⃣ Update Last Customer & Item ===
        [HttpPatch("{id}/laststate/update")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> UpdateLastState(int id, [FromBody] UpdateLastStateRequest request)
        {
            var player = await _context.Players.FindAsync(id);
            if (player == null)
                return NotFound("Player tidak ditemukan.");

            player.last_cus = request.LastCustomerId;
            player.last_item = request.LastItemId;

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Last state berhasil diperbarui.",
                last_cus = player.last_cus,
                last_item = player.last_item
            });
        }

        // === 2️⃣ Reset / Hapus Last State ===
        [HttpPatch("{id}/laststate/reset")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ResetLastState(int id)
        {
            var player = await _context.Players.FindAsync(id);
            if (player == null)
                return NotFound("Player tidak ditemukan.");

            player.last_cus = 0;
            player.last_item = 0;

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Last state berhasil direset.",
                last_cus = player.last_cus,
                last_item = player.last_item
            });
        }
        // Model request tambahan
        public class RegisterRequest
        {
            public string Username { get; set; } = string.Empty;
            public string Password { get; set; } = string.Empty;
        }

        public class UpdateRequest
        {
            public string? Username { get; set; }
            public string? Password { get; set; }
            public int Coins { get; set; }                   
            public int TimePlayed { get; set; }                      
            public int lastCus { get; set; }                  
            public int lastItem { get; set; }                 
            public List<int> ItemCollection { get; set; } = new List<int>();
        }

        public class LoginRequest
        {
            public string Username { get; set; } = string.Empty;
            public string Password { get; set; } = string.Empty;
        }

        public class UpdateCoinRequest
        {
            public int Coins { get; set; }
        }

        public class AddItemRequest
        {
            public int NewItem { get; set; }
        }
        public class UpdateLastStateRequest
        {
            public int LastCustomerId { get; set; }
            public int LastItemId { get; set; }
        }
    }
}
