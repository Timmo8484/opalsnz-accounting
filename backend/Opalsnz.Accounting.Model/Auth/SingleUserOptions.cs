namespace Opalsnz.Accounting.Model.Auth;

// Bound from the "SingleUser" configuration section. PasswordHash is a PBKDF2 hash, never plaintext.
public class SingleUserOptions
{
    public const string SectionName = "SingleUser";

    public string Username { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
}
