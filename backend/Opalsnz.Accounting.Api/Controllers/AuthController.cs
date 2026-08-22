using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Opalsnz.Accounting.Model.Auth;
using Opalsnz.Accounting.Service.Auth;

namespace Opalsnz.Accounting.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController(IAuthService authService) : ControllerBase
{
    [HttpPost("login")]
    [AllowAnonymous]
    public ActionResult<LoginResponse> Login(LoginRequest request)
    {
        var response = authService.Login(request.Username, request.Password);
        return response is null ? Unauthorized() : Ok(response);
    }
}
