% =========================================================================
%> @section INTRO ReadParameterValue
%>
%> - �پ��� ������ �������� �д� �Լ�
%>
%> @version 0.1
%> @callgraph
%> @callergraph
%>
%> @retval value            : ��ȯ�Ǵ� ������
%>
%> @param fid               : �Է� ������ id
%> @param parameterName     : �о���� ������
%> @param dataType          : ������ �ڷ���
% =========================================================================
function value = ReadParameterValue(fid,parameterName,dataType)
%
%

% ��� ����
NUMERIC = 1;
% STRING = 2;

% ���� ���� �����Ѵ�.
headerLine = fgets(fid);

% dataType�� ���� ������ �д´�.
if dataType == NUMERIC
    
    tmpValue = fgetl(fid);
    value = sscanf(tmpValue,'%f',1);
    
else
% elseif dataType == STRING : �ٸ� �ڷ����� �����Ƿ� else�� �̿���
    
    tmpValue = fgetl(fid);
    value = sscanf(tmpValue,'%s',1);
    
end

% parameterName�� �о���� ���� ���� �������� �´��� Ȯ���Ѵ�.
title = sscanf(headerLine,'%s',1);

if (strcmp(title,parameterName) == false)
    
    fprintf('���� %s�� ���Ͽ��� �о�� �� �����ε�, ',parameterName);
    fprintf('�̿� �ٸ� ������ �о���̷��� �Ѵ�.\n');
    fprintf('������ ���� �ٰ� ���� �ʱ� �������� ������ ����.\n');
    fprintf('%s : %s\n',headerLine,value);
    error('ReadParameterValue �Լ� ���� �߻�\n');
    
end

end % ReadParameterValue end