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
        public async Task<IActionResult> UpdatePlayer(int id, Player updated)
        {
            var player = await _context.Players.FindAsync(id);
            if (player == null)
                return NotFound();

            // Update kolom yang ada di tabel
            player.username = updated.username;
            player.password = updated.password;
            player.item = updated.item;

            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
