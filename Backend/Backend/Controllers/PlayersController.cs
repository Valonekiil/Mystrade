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
                .OrderByDescending(p => p.item)
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

        // REGISTER Player baru
        [HttpPost]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<Player>> AddPlayer([FromBody] RegisterRequest request)
        {
            if (request == null)
                return BadRequest("Body tidak boleh kosong.");

            if (string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password))
                return BadRequest("Username dan password wajib diisi.");

            var player = new Player
            {
                username = request.Username,
                password = request.Password,
                item = 0,
                TimePlayed = 0,
                LastPlayed = DateTime.UtcNow,
                ItemCollection = new List<int>()
            };

            _context.Players.Add(player);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetPlayer), new { id = player.Id }, player);
        }

        // UPDATE data player
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
            }

            await _context.SaveChangesAsync();
            return Ok(player);
        }

        // PATCH item count (gunakan JSON)
        [HttpPatch("{id}/items")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<Player>> UpdatePlayerItems(int id, [FromBody] UpdateItemRequest request)
        {
            if (request == null)
                return BadRequest("Body tidak boleh kosong.");

            var player = await _context.Players.FindAsync(id);
            if (player == null)
                return NotFound();

            player.item = request.Items;
            await _context.SaveChangesAsync();

            return Ok(player);
        }

        // Tambah item ke koleksi player
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

            if (!player.ItemCollection.Contains(request.NewItem))
                player.ItemCollection.Add(request.NewItem);

            await _context.SaveChangesAsync();

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

        // LOGIN
        [HttpPost("login")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<ActionResult<Player>> Login([FromBody] LoginRequest request)
        {
            if (request == null)
                return BadRequest("Body tidak boleh kosong.");

            if (string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password))
                return BadRequest("Username dan password wajib diisi.");

            var player = await _context.Players
                .FirstOrDefaultAsync(p => p.username == request.Username && p.password == request.Password);

            if (player == null)
                return Unauthorized("Username atau password salah.");

            return Ok(player);
        }

        // LEADERBOARD
        [HttpGet("leaderboard")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<ActionResult<IEnumerable<object>>> GetLeaderboard()
        {
            var players = await _context.Players
                .OrderByDescending(p => p.item)
                .ThenBy(p => p.TimePlayed)
                .ToListAsync();

            var leaderboard = players.Select((p, index) => new
            {
                Rank = index + 1,
                p.username,
                p.item,
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
        }

        public class LoginRequest
        {
            public string Username { get; set; } = string.Empty;
            public string Password { get; set; } = string.Empty;
        }

        public class UpdateItemRequest
        {
            public int Items { get; set; }
        }

        public class AddItemRequest
        {
            public int NewItem { get; set; }
        }
    }
}
