using Microsoft.AspNetCore.Mvc.RazorPages;
using Entitas.Domain.Entities;

namespace Entitas.Pages;

public class IndexModel : PageModel
{
    public Seller Seller { get; private set; } = null!;

    public void OnGet()
    {
        Seller = new Seller(Guid.NewGuid(), "Bima Santoso Store", "bima@example.com");
    }
}
