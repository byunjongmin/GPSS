% =========================================================================
%> @section INTRO ReadElevation
%>
%> - ���Ϸκ��� �ʱ� ������ ���� �о�鿩 �̸� ��ȯ�ϴ� �Լ�
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%>
%> @retval elev         : �ʱ� ���� �� [m] 
%>
%> @param elevationFile : �ʱ� ������ ��ϵ� ���� �̸�
% =========================================================================
function elev = ReadElevation(elevationFile)
%
%

% �ʱ� ���� ������ ����.
fid=fopen(elevationFile,'r');

if fid==-1
    error('�ʱ� ���� ������ �ҷ����µ��� ������ �߻��߽��ϴ�.\n');
end

% �켱 �ʱ� ������ ��� ���� ���� ������ �о���δ�.
mRows = fscanf(fid,'%i',1);
nCols = fscanf(fid,'%i',1);

% �������� �ʱ� ������ ���� �о���δ�.
elev = fscanf(fid,'%f',[mRows,nCols]);

fclose(fid);

end % ReadElevation end