namespace Lotly.Domain.Entities;

public sealed class Seller
{
    public Seller(Guid id, string storeName, string email)
    {
        if (id == Guid.Empty)
            throw new ArgumentException("ID seller tidak boleh kosong.", nameof(id));
        if (string.IsNullOrWhiteSpace(storeName))
            throw new ArgumentException("Nama toko wajib diisi.", nameof(storeName));
        if (string.IsNullOrWhiteSpace(email))
            throw new ArgumentException("Email seller wajib diisi.", nameof(email));

        Id = id;
        StoreName = storeName.Trim();
        Email = email.Trim();
    }

    public Guid Id { get; }
    public string StoreName { get; private set; }
    public string Email { get; private set; }

    public void ChangeProfile(string storeName, string email)
    {
        if (string.IsNullOrWhiteSpace(storeName))
            throw new ArgumentException("Nama toko wajib diisi.", nameof(storeName));
        if (string.IsNullOrWhiteSpace(email))
            throw new ArgumentException("Email seller wajib diisi.", nameof(email));

        StoreName = storeName.Trim();
        Email = email.Trim();
    }

}
