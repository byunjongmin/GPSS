% =========================================================================
%> @section INTRO ReadElevation
%>
%> - 파일로부터 초기 지형의 고도를 읽어들여 이를 반환하는 함수
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%>
%> @retval elev         : 초기 지형 고도 [m] 
%>
%> @param elevationFile : 초기 지형이 기록된 파일 이름
% =========================================================================
function elev = ReadElevation(elevationFile)
%
%

% 초기 지형 파일을 연다.
fid=fopen(elevationFile,'r');

if fid==-1
    error('초기 지형 파일을 불러오는데서 에러가 발생했습니다.\n');
end

% 우선 초기 지형의 행과 열에 대한 정보를 읽어들인다.
mRows = fscanf(fid,'%i',1);
nCols = fscanf(fid,'%i',1);

% 다음으로 초기 지형의 고도를 읽어들인다.
elev = fscanf(fid,'%f',[mRows,nCols]);

fclose(fid);

end % ReadElevation end