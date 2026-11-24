namespace Lotly.Domain.Entities;

public sealed class Listing
{
    public Listing(Guid id, Guid sellerId, string title)
    {
        if (id == Guid.Empty)
            throw new ArgumentException("ID listing tidak boleh kosong.", nameof(id));
        if (sellerId == Guid.Empty)
            throw new ArgumentException("Seller wajib ditentukan.", nameof(sellerId));
        if (string.IsNullOrWhiteSpace(title))
            throw new ArgumentException("Judul listing wajib diisi.", nameof(title));

        Id = id;
        SellerId = sellerId;
        Title = title.Trim();
    }

    public Guid Id { get; }
    public Guid SellerId { get; }
    public string Title { get; private set; }

    public void ChangeTitle(string title)
    {
        if (string.IsNullOrWhiteSpace(title))
            throw new ArgumentException("Judul listing wajib diisi.", nameof(title));

        Title = title.Trim();
    }
}
