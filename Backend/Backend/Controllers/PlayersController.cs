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

        // GET: api/players
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Player>>> GetPlayers()
        {
            var players = await _context.Players
                .OrderByDescending(p => p.item)
                .ToListAsync();

            return Ok(players);
        }

        // GET: api/players/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Player>> GetPlayer(int id)
        {
            var player = await _context.Players.FindAsync(id);
            if (player == null)
                return NotFound();

            return player;
        }

        // POST: api/players
        [HttpPost]
        public async Task<ActionResult<Player>> AddPlayer(Player player)
        {
            if (string.IsNullOrWhiteSpace(player.username) || string.IsNullOrWhiteSpace(player.password))
                return BadRequest("Username dan password wajib diisi.");

            _context.Players.Add(player);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetPlayers), new { id = player.Id }, player);
        }

        // PUT: api/players/5  
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdatePlayer(int id, Player player)
        {
            if (id != player.Id)
                return BadRequest();

            _context.Entry(player).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!PlayerExists(id))
                    return NotFound();
                else
                    throw;
            }

            return Ok(player);
        }

        // PATCH: api/players/5/items
        [HttpPatch("{id}/items")]
        public async Task<ActionResult<Player>> UpdatePlayerItems(int id, [FromBody] int items)
        {
            var player = await _context.Players.FindAsync(id);
            if (player == null)
                return NotFound();

            player.item = items;
            await _context.SaveChangesAsync();

            return Ok(player);
        }
        // POST: api/players/login
        [HttpPost("login")]
        public async Task<ActionResult<Player>> Login([FromBody] LoginRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password))
                return BadRequest("Username dan password wajib diisi.");

            var player = await _context.Players
                .FirstOrDefaultAsync(p => p.username == request.Username && p.password == request.Password);

            if (player == null)
                return Unauthorized("Username atau password salah.");

            return Ok(player);
        }

        // DTO untuk login
        public class LoginRequest
        {
            public string Username { get; set; } = string.Empty;
            public string Password { get; set; } = string.Empty;
        }
        private bool PlayerExists(int id)
        {
            return _context.Players.Any(e => e.Id == id);
        }
    }
}
