namespace Opalsnz.Accounting.Model.Dto;

public class ExpenseCategoryDto
{
    public long Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal DefaultClaimPercent { get; set; }
    public bool HasGst { get; set; }
    public bool IsActive { get; set; }
}
