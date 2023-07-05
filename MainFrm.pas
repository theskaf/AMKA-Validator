unit MainFrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.DateUtils,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  FMX.DateTimeCtrls;

type
  TfrmMain = class(TForm)
    grpbGender: TGroupBox;
    rbMale: TRadioButton;
    rbFemale: TRadioButton;
    edtAMKA: TEdit;
    btnCalc: TButton;
    memoRes: TMemo;
    lblBDate: TLabel;
    dtBDate: TDateEdit;
    btnExit: TButton;
    procedure FormResize(Sender: TObject);
    procedure btnCalcClick(Sender: TObject);
    procedure edtAMKAKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure edtAMKAKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure btnExitClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

procedure TfrmMain.edtAMKAKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  InputText: string;
  NonNumericChars: string;
begin
  InputText := edtAMKA.Text;

  NonNumericChars := InputText.Replace('0', '').Replace('1', '').Replace('2', '')
    .Replace('3', '').Replace('4', '').Replace('5', '').Replace('6', '').Replace('7', '')
    .Replace('8', '').Replace('9', '');

  if NonNumericChars <> '' then
    edtAMKA.Text := InputText.Replace(NonNumericChars, '');
end;

procedure TfrmMain.edtAMKAKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
//Instead of Win VCL's TfrmMain.edtAMKAKeyDown(Sender: TObject; var Key: Char);
begin
  //In a multiplatform Delphi project, the OnKeyDown event passes the Key parameter as an Integer instead of a Word as in the VCL framework
  //--- if not (Key in ['0'..'9', '.', '-', #8]) then Key := #0;
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  //ClientHeight := 480;
  //ClientWidth := 640;
end;

procedure TfrmMain.btnExitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmMain.btnCalcClick(Sender: TObject);
    function CalculateLuhnCheckDigit(const Number: string): Integer;
    var
      Sum: Integer;
      Digit: Integer;
      i: Integer;
    begin
      Sum := 0;

      for i := Length(Number) - 1 downto 1 do
      begin
        Digit := StrToIntDef(Number[i], -1);
        if Digit = -1 then
          Continue;

        if i mod 2 = 0 then
          Digit := Digit * 2;

        if Digit > 9 then
          Digit := Digit - 9;

        Sum := Sum + Digit;
      end;

      Result := (10 - (Sum mod 10)) mod 10;
    end;
var
  iCounter, TenthDigit, tmpCheckDigit,
  fmsTmpInt, fmsYATmpInt: Integer;
  FormattedDate,
  fmsTmpStr, fmsYATmpStr: string;
  DateEditValue, CompareDate, amkaDate: TDateTime;
begin
  memoRes.Lines.Clear;
  iCounter := 0;

  if Length(edtAMKA.Text) <> 11 then
  begin
    memoRes.Lines.Add('Λάθος ΑΜΚΑ: Το μήκος του δεν είναι 11 χαρακτήρες.');
    Exit;
  end;



  DateEditValue := dtBDate.Date;
  FormattedDate := FormatDateTime('yyyy-MM-dd', DateEditValue) + 'T00:00:00.000Z';

  CompareDate := ISO8601ToDate(FormattedDate, False);

  FormattedDate := Copy(Trim(edtAMKA.Text), 1, 6);

  //I could have as well get the year from the entered one, but then it's not exactly comparison innit >>>>>>>>>>>>>>>>>>>
  //Hence, spaghetti code inc

  fmsTmpStr := Copy(FormattedDate, 1, 2);
  fmsTmpInt := StrToInt(fmsTmpStr);

  fmsYATmpStr := Copy(DateToISO8601(Now, False), 3, 2);
  fmsYATmpInt := StrToInt(fmsYATmpStr);

  if (fmsTmpInt >= 0) and (fmsTmpInt <= fmsYATmpInt) then
    FormattedDate := '20' + FormattedDate
  else
    FormattedDate := '19' + FormattedDate;

  //That being said, the following is trully an interesting read:  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  // https://publications.ics.forth.gr/_publications/ssn.wpes09.pdf


  FormattedDate := Copy(FormattedDate, 1, 4) + '-' + Copy(FormattedDate, 5, 2) + '-' + Copy(FormattedDate, 7, 2) + 'T00:00:00.000Z';

  amkaDate := ISO8601ToDate(FormattedDate, False);

  FormattedDate := '';

  if CompareDate = amkaDate then
  begin
    memoRes.Lines.Add('Πέρασε το σημείο ελέγχου των ημερομηνιών.');
  end
  else if CompareDate < amkaDate then
  begin
    Inc(iCounter);
    memoRes.Lines.Add('Ημ. ΑΜΚΑ > γέννησης: Το σημείο ελέγχου ημερομηνιών απέτυχε.');
  end
  else
  begin
    Inc(iCounter);
    memoRes.Lines.Add('Ημ. ΑΜΚΑ < γέννησης: Το σημείο ελέγχου ημερομηνιών απέτυχε.');
  end;



  TenthDigit := StrToIntDef(Trim(edtAMKA.Text)[10], -1);
  if (TenthDigit <> -1) and (TenthDigit mod 2 = 0) then
  begin
    if rbFemale.IsChecked then
      memoRes.Lines.Add('Πέρασε το σημείο ελέγχου φύλου (γυναίκα).')
    else
    begin
      Inc(iCounter);
      memoRes.Lines.Add('Το σημείο ελέγχου φύλου απέτυχε.');
    end;
  end
  else
  begin
    //  ShowMessage('The 10th digit is odd.'); //man
    if rbMale.IsChecked then
      memoRes.Lines.Add('Πέρασε το σημείο ελέγχου φύλου (άντρας).')
    else
    begin
      Inc(iCounter);
      memoRes.Lines.Add('Το σημείο ελέγχου φύλου απέτυχε.');
    end;
  end;

  tmpCheckDigit := CalculateLuhnCheckDigit(Trim(edtAMKA.Text));
  if ( Copy(Trim(edtAMKA.Text), 11, 1) =  IntToStr(tmpCheckDigit) ) then
  begin
    memoRes.Lines.Add('Πέρασε το σημείο ελέγχου modulus 10.')
  end
  else
  begin
    Inc(iCounter);
    memoRes.Lines.Add('Το σημείο ελέγχου modulus 10 απέτυχε (' + IntToStr(tmpCheckDigit) + ').')
  end;

  memoRes.Lines.Add('');

  if iCounter > 0 then
    memoRes.Lines.Add('To AMKA φαίνεται να μην είναι σωστό.')
  else
    memoRes.Lines.Add('To AMKA φαίνεται να είναι σωστό.');
end;

end.
