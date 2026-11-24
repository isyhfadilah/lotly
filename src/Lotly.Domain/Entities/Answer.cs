namespace Lotly.Domain.Entities;

public sealed class Answer
{
    public Answer(Guid id, Guid questionId, Guid memberId, string text)
    {
        if (id == Guid.Empty)
            throw new ArgumentException("ID jawaban tidak boleh kosong.", nameof(id));
        if (questionId == Guid.Empty)
            throw new ArgumentException("Pertanyaan wajib ditentukan.", nameof(questionId));
        if (memberId == Guid.Empty)
            throw new ArgumentException("Member wajib ditentukan.", nameof(memberId));
        if (string.IsNullOrWhiteSpace(text))
            throw new ArgumentException("Isi jawaban wajib diisi.", nameof(text));

        Id = id;
        QuestionId = questionId;
        MemberId = memberId;
        Text = text.Trim();
    }

    public Guid Id { get; }
    public Guid QuestionId { get; }
    public Guid MemberId { get; }
    public string Text { get; private set; }

    public void EditText(string text)
    {
        if (string.IsNullOrWhiteSpace(text))
            throw new ArgumentException("Isi jawaban wajib diisi.", nameof(text));

        Text = text.Trim();
    }
}
