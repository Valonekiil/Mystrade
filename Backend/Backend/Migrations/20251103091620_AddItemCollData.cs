using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Backend.Migrations
{
    /// <inheritdoc />
    public partial class AddItemCollData : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ItemCollection",
                table: "Players");

            migrationBuilder.RenameColumn(
                name: "ItemCollectionJson",
                table: "Players",
                newName: "ItemCollectionData");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "ItemCollectionData",
                table: "Players",
                newName: "ItemCollectionJson");

            migrationBuilder.AddColumn<string>(
                name: "ItemCollection",
                table: "Players",
                type: "TEXT",
                nullable: false,
                defaultValue: "");
        }
    }
}
