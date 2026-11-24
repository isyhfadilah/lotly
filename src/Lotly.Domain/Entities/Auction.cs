namespace Lotly.Domain.Entities;

public sealed class Auction
{
    public Auction(Guid id, Guid listingId, DateTimeOffset startsAt, DateTimeOffset endsAt)
    {
        if (id == Guid.Empty)
            throw new ArgumentException("ID lelang tidak boleh kosong.", nameof(id));
        if (listingId == Guid.Empty)
            throw new ArgumentException("Listing wajib ditentukan.", nameof(listingId));
        if (endsAt <= startsAt)
            throw new ArgumentException("Waktu akhir lelang harus setelah waktu mulai.", nameof(endsAt));

        Id = id;
        ListingId = listingId;
        StartsAt = startsAt;
        EndsAt = endsAt;
    }

    public Guid Id { get; }
    public Guid ListingId { get; }
    public DateTimeOffset StartsAt { get; }
    public DateTimeOffset EndsAt { get; }
}
