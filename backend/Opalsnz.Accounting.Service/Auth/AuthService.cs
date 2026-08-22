using Microsoft.Extensions.Options;
using Opalsnz.Accounting.Model.Auth;

namespace Opalsnz.Accounting.Service.Auth;

public interface IAuthService
{
    LoginResponse? Login(string username, string password);
}

// Single hard-coded credential (from config/env), not a Users table - see architecture-decisions.md.
public class AuthService(
    IOptions<SingleUserOptions> singleUserOptions,
    IPasswordHasher passwordHasher,
    IJwtTokenService jwtTokenService) : IAuthService
{
    private readonly SingleUserOptions _user = singleUserOptions.Value;

    public LoginResponse? Login(string username, string password)
    {
        if (!string.Equals(username, _user.Username, StringComparison.Ordinal))
        {
            return null;
        }

        if (string.IsNullOrEmpty(_user.PasswordHash) || !passwordHasher.Verify(password, _user.PasswordHash))
        {
            return null;
        }

        return jwtTokenService.CreateToken(username);
    }
}
