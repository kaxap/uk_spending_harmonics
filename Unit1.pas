unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Math;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    btnStart: TButton;
    ProgressBar1: TProgressBar;
    Panel2: TPanel;
    memo: TRichEdit;
    tmrEstimator: TTimer;
    lblEstimatedTime: TLabel;
    procedure btnStartClick(Sender: TObject);
    procedure tmrEstimatorTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    started: Boolean;
    seconds: Integer;
    procedure AddMessage(const msg: String; Color: TColor = clBlack;
      size: Integer = 14; style: TFontStyles = []);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  data: array[1..48] of Real = (0.4400, 3.1982, 3.3743, 4.1771, 4.1190, 2.8467, 2.6322, 4.1904,
    5.0231, 7.2800, 10.3453, 14.2288, 14.5533, 11.5171, 16.6372, 21.6328,
    22.7073, 23.1794, 19.8064, 19.3560, 18.4091, 17.1979, 12.8715,
    9.6976, 0.5134, -7.0923, -1.5162, 12.8463, 28.4999, 48.2350, 38.5317,
    34.4336, 39.5281, 30.0362, 7.8871, -3.8499, -17.0916, -7.0828,
    10.5399, 22.7527, 31.7045, 43.7520, 20.1719, 40.4446, 62.2287,
    145.4002, 152.4235, 144.8785);
  data_mean, data_dist: Real;
implementation

uses uCorrelation;

{$R *.dfm}

procedure TForm1.btnStartClick(Sender: TObject);
//10 + 140 Sin[(m x - d2)/d]/((m x - d2)/d)
//x->[1..48]

const MAX_ITER = 1000 * 1000 * 1000;
      RESOLUTION = 100;
      RESOLUTION_STR = '.3';
      GUI_PROGRESS_STEP = 10000;
      SIZE_PATH_ALLOCATION = 1000;

  function func(const x, shift, divizor, mul, cossh, cosmul,
    r_mul, r_pow, r_koef: Real): Real;
  begin
    try
      Result := -r_mul/(Power(r_pow, r_koef * x)) + shift + (cossh + cosmul * Cos(divizor)) * mul*Sin(divizor)/divizor;
    except
      Result := x;
    end;  
    //Result := shift + (cossh + cosmul * Cos(divizor)) * mul*Sin(divizor)/divizor;
    //Result := shift + mul*Sin(divizor)/divizor / (cossh + cosmul * Cos(divizor));
    //Result := mul * Sin(shift + x) + cosmul + Cos(cossh + x);
  end;

var
  i, j, k, x: Integer;
  m, r: Real;
  cor, max_cor, cor_m, cor_shift, cor_mul, cor_cossh, cor_cosmul: Real;
  cor_r_mul, cor_r_pow, cor_r_koef: Real;
  sum, min_sum, sum_m, sum_shift, sum_mul, sum_cossh, sum_cosmul: Real;
  sum_r_mul, sum_r_pow, sum_r_koef: Real;
  shift, mul, cossh, cosmul, r_mul, r_pow, r_koef: Real;
  divizor: Real;
  step: Integer;
  v, s: String;
  path_m, path_shift, path_mul: array of Real;
  path_index_m, path_index_shift: Integer;
  simulation: array[1..48] of Real;
  simulation_mean, simulation_dist: Real;
begin

  if started then
  begin
    started := False;
    btnStart.Caption := 'Start simulation';
    AddMessage('Simulation stopped by user.', clRed, 12, []);
    Exit;
  end;

  started := True;
  btnStart.Caption := 'Stop simulation';
  seconds := 0;
  tmrEstimator.Enabled := True;

  DecimalSeparator := '.';

  AddMessage('Starting simulation...', clBlack, 14, [fsBold]);
  AddMessage(Format('Max iterations = %d, Resolution =1/%d', [MAX_ITER,
    RESOLUTION]), $777777, 14, [fsItalic]);

  Randomize;
  max_cor := 0.0;
  min_sum := 10000000.0;
  ProgressBar1.Position := 0;
  ProgressBar1.Max := MAX_ITER;
  step := 0;

  path_index_m := 0;
  path_index_shift := 0;
  SetLength(path_m, SIZE_PATH_ALLOCATION);
  SetLength(path_shift, SIZE_PATH_ALLOCATION);

  for i := 1 to MAX_ITER do
  begin
    {shift := -20 + Random( 40 * RESOLUTION ) / RESOLUTION;
    mul := 120 + Random(60 * RESOLUTION) / RESOLUTION;
    m := -20 + Random( 40 * RESOLUTION ) / RESOLUTION;
    cossh := (-15 + Random(30 * RESOLUTION) / RESOLUTION) / 10;
    cosmul := (-15 + Random(30 * RESOLUTION) / RESOLUTION) / 10;}

    shift := -50 + Random( 100 * RESOLUTION ) / RESOLUTION;
    mul := 100 + Random(80 * RESOLUTION) / RESOLUTION;
    m := -50 + Random( 100 * RESOLUTION ) / RESOLUTION;
    cossh := (-50 + Random(100 * RESOLUTION) / RESOLUTION) / 10;
    cosmul := (-50 + Random(100 * RESOLUTION) / RESOLUTION) / 10;

    r_mul := (1 + Random(30 * RESOLUTION) / RESOLUTION);
    r_pow := (1 + Random(2 * RESOLUTION) / RESOLUTION);
    r_koef := (1 + Random(2 * RESOLUTION) / RESOLUTION);

    sum := 0.0;
    for x := Low(simulation) to High(simulation) do
    begin
      divizor := (m*x - 48*m);
      if divizor <> 0.0 then
        r := func(x, shift, divizor, mul, cossh, cosmul, r_mul, r_pow, r_koef)
      else
        r := shift + mul;


      sum := sum + Abs(r - data[x]);
      simulation[x] := r;
    end;

    //get correlation
    cor := getCorrelation(simulation, data, data_dist, data_mean);

    if cor > max_cor then
    begin
      max_cor := cor;
      cor_m := m;
      cor_shift := shift;
      cor_mul := mul;
      cor_cossh := cossh;
      cor_cosmul := cosmul;
      cor_r_mul := r_mul;
      cor_r_pow := r_pow;
      cor_r_koef := r_koef;

      //store variables
      path_m[path_index_m] := cor_m;
      Inc(path_index_m);

      path_shift[path_index_shift] := cor_shift;
      Inc(path_index_shift);

      //allocate more memory if necessary
      if (Length(path_m) = path_index_m) then
        SetLength(path_m, Length(path_m) + SIZE_PATH_ALLOCATION);

      if (Length(path_shift) = path_index_shift) then
        SetLength(path_shift, Length(path_shift) + SIZE_PATH_ALLOCATION);
    end;

    if sum < min_sum then
    begin
      min_sum := sum;
      sum_m := m;
      sum_shift := shift;
      sum_mul := mul;
      sum_cossh := cossh;
      sum_cosmul := cosmul;
      sum_r_mul := r_mul;
      sum_r_pow := r_pow;
      sum_r_koef := r_koef;
    end;

    Inc(step);

    if step >= GUI_PROGRESS_STEP then
    begin
      step := 0;
      ProgressBar1.StepBy(GUI_PROGRESS_STEP);
      if NOT started then
        Exit;
      Application.ProcessMessages;
    end;
  end;

  AddMessage('Simulation complete.', clBlack, 14, [fsBold]);

  //output data
  AddMessage(Format('Max correlation = %.3f', [max_cor]), $CC7800, 14, [fsBold]);
  v := '%' + RESOLUTION_STR + 'f';
  s := Format('Values for correlation: m = %s, shift = %s, mul = %s, cossh = %s, cosmul = %s, r_mul = %s, r_pow = %s, r_koef = %s', [v, v, v, v, v, v, v, v]);
  AddMessage(Format(s, [cor_m, cor_shift, cor_mul, cor_cossh, cor_cosmul, cor_r_mul, cor_r_pow, cor_r_koef]), clRed, 14, [fsBold]);

  AddMessage(Format('Min sum = %.3f', [min_sum]), $CC7800, 14, [fsBold]);
  s := Format('Values for sum: m = %s, shift = %s, mul = %s, cossh = %s, cosmul = %s, r_mul = %s, r_pow = %s, r_koef = %s', [v, v, v, v, v, v, v, v]);
  AddMessage(Format(s, [sum_m, sum_shift, sum_mul, sum_cossh, sum_cosmul, sum_r_mul, sum_r_pow, sum_r_koef]), clRed, 14, [fsBold]);

  s := '';
  for x := Low(data) to High(data) do
  begin
    divizor := (cor_m*x - 48*cor_m);
    if divizor <> 0.0 then
      r := func(x, cor_shift, divizor, cor_mul, cor_cossh, cor_cosmul,
        cor_r_mul, cor_r_pow, cor_r_koef)
    else
      r := cor_shift + cor_mul;

    if x <> High(data) then
      s := s + Format('%f, ', [r])
    else
      s := s + Format('%f', [r]);
  end;

  AddMessage('Output data for correlation:', clBlack, 14, [fsUnderline]);
  AddMessage(s, clBlack, 10, []);

  s := '';
  for x := Low(data) to High(data) do
  begin
    divizor := (sum_m*x - 48*sum_m);
    if divizor <> 0.0 then
      r := func(x, sum_shift, divizor, sum_mul, sum_cossh, sum_cosmul,
        sum_r_mul, sum_r_pow, sum_r_koef)
    else
      r := sum_shift + sum_mul;

    if x <> High(data) then
      s := s + Format('%f, ', [r])
    else
      s := s + Format('%f', [r]);
  end;

  AddMessage('Output data for sum:', clBlack, 14, [fsUnderline]);
  AddMessage(s, clBlack, 10, []);

  if MessageBox(Handle, 'Output paths?', 'paths', MB_YESNO) = idYes then
  begin
    s := '';

    Dec(path_index_m);
    for i := 0 to path_index_m do
    begin
      if i <> path_index_m then
        s := s + Format(v + ', ', [ path_m[i] ])
      else
        s := s + Format(v, [ path_m[i] ]);
    end;

    AddMessage('');
    AddMessage('Output path_m', clBlack, 18, [fsUnderline]);
    AddMessage(s, $555555, 8, []);

    s := '';

    Dec(path_index_shift);
    for i := 0 to path_index_shift do
    begin
      if i <> path_index_shift then
        s := s + Format(v + ', ', [ path_shift[i] ])
      else
        s := s + Format(v, [ path_shift[i] ]);
    end;

    AddMessage('');
    AddMessage('Output path_d', clBlack, 18, [fsUnderline]);
    AddMessage(s, $555555, 8, []);
  end;

  SetLength(path_m, 0);
  SetLength(path_shift, 0);

  started := False;
  btnStart.Caption := 'Start simulation';
end;

procedure TForm1.AddMessage(const msg: String; Color: TColor = clBlack;
  size: Integer = 14; style: TFontStyles = []);
var
  i: Integer;
begin
  i := memo.Perform(WM_GETTEXTLENGTH, 0, 0);
  memo.Lines.Add(msg);
  memo.SelStart := i;
  memo.SelLength := memo.Perform(WM_GETTEXTLENGTH, 0, 0) - i;
  memo.SelAttributes.Size := size;
  memo.SelAttributes.Style := style;
  memo.SelAttributes.Color := Color;
  memo.SelStart := memo.Perform(WM_GETTEXTLENGTH, 0, 0);
  //memo.SelLength := 0;
  memo.Perform(WM_VSCROLL, SB_BOTTOM, 0);
  Application.ProcessMessages;

end;

procedure TForm1.tmrEstimatorTimer(Sender: TObject);

  function SecondsToStr(sec: Integer): String;
  var
    hh, mm, ss: Integer;
  begin
    hh := sec div 3600;
    mm := sec div 60 - hh * 60;
    ss := sec mod 60;
    Result := Format('%.2d:%.2d:%.2d', [hh, mm, ss]);
  end;

var
  estimated: Integer;
  pos, max, res: Integer;
  speed: Double;
begin
  if NOT started then
  begin
    tmrEstimator.Enabled := False;
    Exit;
  end;

  Inc(seconds);
  pos := ProgressBar1.Position;
  max := ProgressBar1.Max;
  res := max - pos;
  if res = 0 then
    Exit;

  speed := pos / seconds;
  if speed = 0 then
    Exit;
    
  estimated := Trunc(res / speed);

  lblEstimatedTime.Caption := Format('Elapsed: %s, Estimated: %s',
    [SecondsToStr(seconds), SecondsToStr(estimated)]);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  data_mean := getMean(data);
  data_dist := getDist(data, data_mean);
  AddMessage(Format('sample mean = %f, sample dist = %f',[data_mean,
    data_dist]), $666666, 12, []);
end;

end.
