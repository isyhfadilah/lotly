namespace Lotly.Domain.Entities;

public sealed class WinningBid
{
    public WinningBid(Guid id, Guid auctionId, Guid memberId)
    {
        if (id == Guid.Empty)
            throw new ArgumentException("ID winning bid tidak boleh kosong.", nameof(id));
        if (auctionId == Guid.Empty)
            throw new ArgumentException("Auction wajib ditentukan.", nameof(auctionId));
        if (memberId == Guid.Empty)
            throw new ArgumentException("Member pemenang wajib ditentukan.", nameof(memberId));

        Id = id;
        AuctionId = auctionId;
        MemberId = memberId;
    }

    public Guid Id { get; }
    public Guid AuctionId { get; }
    public Guid MemberId { get; }
}
