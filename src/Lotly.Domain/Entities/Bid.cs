namespace Lotly.Domain.Entities;

public sealed class Bid
{
    public Bid(Guid id, Guid auctionId, Guid memberId, decimal amount, DateTimeOffset placedAt)
    {
        if (id == Guid.Empty)
            throw new ArgumentException("ID bid tidak boleh kosong.", nameof(id));
        if (auctionId == Guid.Empty)
            throw new ArgumentException("Auction wajib ditentukan.", nameof(auctionId));
        if (memberId == Guid.Empty)
            throw new ArgumentException("Member penawar wajib ditentukan.", nameof(memberId));
        if (amount <= 0)
            throw new ArgumentOutOfRangeException(nameof(amount), "Nilai bid harus lebih dari nol.");

        Id = id;
        AuctionId = auctionId;
        MemberId = memberId;
        Amount = amount;
        PlacedAt = placedAt;
    }

    public Guid Id { get; }
    public Guid AuctionId { get; }
    public Guid MemberId { get; }
    public decimal Amount { get; }
    public DateTimeOffset PlacedAt { get; }
}
