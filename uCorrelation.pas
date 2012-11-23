unit uCorrelation;

interface
   //uses SysUtils;
   uses Dialogs;

   function getCorrelation(x, y: array of Real): Real; overload;
   function getCorrelation(dist1, dist2,
     numerator: Real): Real; overload;
    function getCorrelation(x, y: array of Real;
      dist_y, mean_y: Real): Real; overload;
   function getMean(a: array of Real): Real;
   function getDist(a: array of Real; mean: Real): Real;
   function getNumerator(x, y: array of Real; mean_x, mean_y: Real): Real;

implementation

uses SysUtils;

function getCorrelation(x, y: array of Real; dist_y, mean_y: Real): Real;
var
  mean_x, dist_x: Real;
  numerator: Real;
begin
  mean_x := getMean(x);
  dist_x := getDist(x, mean_x);
  if dist_x = 0.0 then
  begin
    Result := 0.0;
    Exit;
  end;

  numerator := getNumerator(x, y, mean_x, mean_y);
  Result := getCorrelation(dist_x, dist_y, numerator);
end;

function getCorrelation(x, y: array of Real): Real; overload;
var
  mean_x, mean_y: Real;
  dist_x, dist_y: Real;
  numerator: Real;
begin
  mean_x := getMean(x);
  mean_y := getMean(y);
  dist_x := getDist(x, mean_x);
  dist_y := getDist(y, mean_y);
  numerator := getNumerator(x, y, mean_x, mean_y);
  Result := getCorrelation(dist_x, dist_y, numerator);
end;

function getCorrelation(dist1, dist2,
    numerator: Real): Real;
begin
  try
    Result := numerator / (dist1 * dist2);
  except
    ShowMessage(Format('Error occured on getCorrelation: numerator = %f, dist1 = %f, dist2 = %f',
      [numerator, dist1, dist2]));
  end;
end;

function getNumerator(x, y: array of Real; mean_x, mean_y: Real): Real;
var
  i, j: Integer;
begin
  if Length(x) <> Length(y) then
    raise Exception.Create('getNumerator: arrays have different lengths');

  Result := 0.0;

  j := Low(y);
  for i := Low(x) to High(x) do
  begin
    Result := Result +
      (x[i] - mean_x) * (y[j] - mean_y);

    Inc(j);
  end;
  
end;

function getDist(a: array of Real; mean: Real): Real;
var
  i: Integer;
begin
  Result := 0.0;
  for i := Low(a) + 1 to High(a) do
  begin
    Result := Result + Sqr(a[i] - mean);
  end;
  Result := Sqrt(Result);
end;

function getMean(a: array of Real): Real;
var
  i: Integer;
begin
  Result := 0.0;
  for i := Low(a) to High(a) do
  begin
    Result := Result + a[i];
  end;

  Result := Result / Length(a);
end;

end.
 