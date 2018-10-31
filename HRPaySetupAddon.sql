/*
	
	HRPaySetupAddon
	The HRPaySetupAddont defines the addons that an employee has that do not come from position assignments.  
	Examples are stipends, longevity, substitutes (non-regular employees), etc.

*/

select 
	DistrictID,
	rtrim(DistrictAbbrev) as DistrictAbbrev,
	DistrictTitle
from tblDistrict

select 
	(select DistrictId from tblDistrict) as OrgID,
	cd.EmployeeID as EmpID,
	CONVERT(VARCHAR(10), cd.EffectiveDate, 110) as DateFrom,
	CONVERT(VARCHAR(10), cd.InactiveDate, 110) as DateThru,
	cd.CompTypeID as AddonID,
	null as DivisionID,
	null as AcademicDeptCode,
	null as DateLongevity,
	(case when isnull(te.PayCycle,0) = 0 then scby.MthWk else te.PayCycle end) as PaycycleID,
	fund.fsAccountID as AcctNumID,
	cd.cdPositionControlID,
	null as OASIEnabled,
	pcd.SlotNum,
	ct.CompType as CompType,
	sm.StepColumn,
	sm.[Value],
	acct.AccountString,
	fund.[Percent]
from tblEmployee te
inner join
	tblCompDetails cd
	on te.EmployeeID = cd.EmployeeID
	and cd.FiscalYear = 2018
	and cd.InactiveDate is null
	and te.TerminateDate is null
inner join
	tblCompType ct
	on cd.CompTypeID = ct.CompTypeID
	and ct.CompType not like '%base%'
inner join
	tblPositionControlDetails pcd
	on cd.cdPositionControlID = pcd.PositionControlID
	and pcd.InactiveDate is null
inner join
	tblSlotCalendarByYear scby
	on scby.SlotCalendarID = pcd.pcSlotCalendarID
	and scby.FiscalYear = 2018
inner join
	tblFundingSlotDetails fund
	on cd.cdPositionControlID = fund.fPositionControlID
	and fund.InactivePayrollId is null
	and isnull(fund.Inactive,0) = 0
	and (fund.EffectivePayrollId = (select max(EffectivePayrollId) from tblFundingSlotDetails where fPositionControlID = pcd.PositionControlID) or fund.EffectivePayrollId is null)
left join
	tblSalaryMatrix sm
	on sm.SalaryMatrixID = cd.SalaryMatrixId
inner join
	tblAccount acct
	on acct.AccountID = fund.fsAccountID
order by cd.EmployeeID asc
