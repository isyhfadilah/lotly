namespace Lotly.Domain.Entities;

public sealed class Question
{
    public Question(Guid id, Guid listingId, Guid memberId, string text)
    {
        if (id == Guid.Empty)
            throw new ArgumentException("ID pertanyaan tidak boleh kosong.", nameof(id));
        if (listingId == Guid.Empty)
            throw new ArgumentException("Listing wajib ditentukan.", nameof(listingId));
        if (memberId == Guid.Empty)
            throw new ArgumentException("Member wajib ditentukan.", nameof(memberId));
        if (string.IsNullOrWhiteSpace(text))
            throw new ArgumentException("Isi pertanyaan wajib diisi.", nameof(text));

        Id = id;
        ListingId = listingId;
        MemberId = memberId;
        Text = text.Trim();
    }

    public Guid Id { get; }
    public Guid ListingId { get; }
    public Guid MemberId { get; }
    public string Text { get; private set; }

    public void EditText(string text)
    {
        if (string.IsNullOrWhiteSpace(text))
            throw new ArgumentException("Isi pertanyaan wajib diisi.", nameof(text));

        Text = text.Trim();
    }
}
