% =========================================================================
%> @section INTRO ReadParameterValue
%>
%> - 다양한 형태의 변수값을 읽는 함수
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%>
%> @retval value            : 반환되는 변수값
%>
%> @param fid               : 입력 파일의 id
%> @param parameterName     : 읽어들일 변수명
%> @param dataType          : 변수의 자료형
% =========================================================================
function value = ReadParameterValue(fid,parameterName,dataType)
%
%

% 상수 정의
NUMERIC = 1;
% STRING = 2;

% 제목 줄을 저장한다.
headerLine = fgets(fid);

% dataType에 따라 변수를 읽는다.
if dataType == NUMERIC
    
    tmpValue = fgetl(fid);
    value = sscanf(tmpValue,'%f',1);
    
else
% elseif dataType == STRING : 다른 자료형이 없으므로 else를 이용함
    
    tmpValue = fgetl(fid);
    value = sscanf(tmpValue,'%s',1);
    
end

% parameterName과 읽어들인 제목 줄의 변수명이 맞는지 확인한다.
title = sscanf(headerLine,'%s',1);

if (strcmp(title,parameterName) == false)
    
    fprintf('변수 %s를 파일에서 읽어야 할 차례인데, ',parameterName);
    fprintf('이와 다른 변수를 읽어들이려고 한다.\n');
    fprintf('현재의 제목 줄과 읽은 초기 변수값은 다음과 같다.\n');
    fprintf('%s : %s\n',headerLine,value);
    error('ReadParameterValue 함수 에러 발생\n');
    
end

end % ReadParameterValue end