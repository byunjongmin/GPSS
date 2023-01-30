/*
 * HillslopeProcessMex.c
 *
 * ���� �� ������ ����ۿ뿡 ���� ������ �β� ��ȭ���� ���ϴ� �Լ�
 * (���� �� ������) ��ݴɷ¿� ���� ��鹰���� �� �̿� ���� �й���
 * * ����: ������ ������ flooded region�� ���ⱸ������ Ȯ������ ���� 1) ����
 *   �ð��� 1���� ��쿡 flooded region������ �������� ���差�� �Ѵ� ���� ����
 *   ���� 2) ��� ������ ���� �̵��̹Ƿ� flooded region�� �������� ���差��
 *   �ʰ��ϴ��� �ʰ����� ���ⱸ�� ���� �̵����� �ʴ´ٰ� ������ 3) ���ⱸ
 *   ���ο� ���� �̿� ���� �й��ϴ� ����� �޶������� ����
 * * ����: HillslopeProcess �Լ�(ver 0.7)�� for �ݺ������� MEX ���Ϸ� ������
 * 
 * [inputFlux ...                   0 ��� �������κ����� ������ [m/dT]
 * ,outputFlux...                   1 �̿� ������ �� ������ [m/dT]
 * ,inputFloodedRegion ...          2 flooded region������ ������ [m/dT]
 * ] = HillslopeProcessMex ...
 * (mRows ...                       0 . �� ����
 * ,nCols ...                       1 . �� ����
 * ,consideringCellsNo) ...         2 . ����ۿ��� �߻��ϴ� �� ��
 *----------------------------- mexGetVariablePtr �Լ��� �����ϴ� ����
 * mexSortedIndicies ...            0 . �������� ���ĵ� ����
 * mexSDSNbrIndicies ...            1 . ���� �� ����
 * n3IthNbrLinearIndicies ...       2 . 3���� 8���� �̿� �� ����
 * flood ...                        3 . flooded region
 * sedimentThick ...                4 . ������ �β�
 * transportCapacityToNbrs ...      5 . �� �̿� ������ ����ۿ� ��ݴɷ�
 * sumTransportCapacityToNbrs ...   6 . �� ����ۿ� ��ݴɷ�
 
 *
 */

# include "mex.h"

/* ��� �Լ� ���� */
void HillslopeProcessMex(
    double * inputFlux,
    double * outputFlux,
    double * inputFloodedRegion,
    mwIndex mRows,
    mwIndex nCols,
    mwSize consideringCellsNo,
    double * mexSortedIndicies,
    double * mexSDSNbrIndicies,
    double * n3IthNbrLinearIndicies,
    double * flood,
    double * sedimentThick,
    double * transportCapacityToNbrs,
    double * sumTransportCapacityToNbrs);

/* Gateway Function */
void mexFunction(int nlhs,       mxArray * plhs[]
                ,int nrhs, const mxArray * prhs[])
{
    /* �Է� ���� ����
     * ����: mxArray �ڷ��� ������ mexGetVariablePtr �Լ��� �̿��Ͽ�
     * ȣ���Լ��� �۾������� �ִ� �������� �����͸� �ҷ��� */
    /* ȣ���Լ� �۾������� ���� */
    const mxArray * mxArray0; /* mexSortedIndicies */
    const mxArray * mxArray1; /* mexSDSNbrIndicies*/
    const mxArray * mxArray2; /* n3IthNbrLinearIndicies */
    const mxArray * mxArray3; /* flood */
    const mxArray * mxArray4; /* sedimentThick */
    const mxArray * mxArray5; /* transportCapacityToNbrs */
    const mxArray * mxArray6; /* sumTransportCapacityToNbrs */
    
    /* �Էº��� ���� �ڷ�  */
    mwIndex mRows;
    mwIndex nCols;
    mwSize consideringCellsNo;
    double * mexSortedIndicies;
    double * mexSDSNbrIndicies;
    double * n3IthNbrLinearIndicies;
    double * flood;
    double * sedimentThick;
    double * transportCapacityToNbrs;
    double * sumTransportCapacityToNbrs;
    
    /* ��� ���� ���� */
    double * dSedimentThick;
    double * inputFlux;
    double * outputFlux;
    double * inputFloodedRegion;
    
    /* �Է� ���� �ʱ�ȭ */
    mRows               = (mwIndex) mxGetScalar(prhs[0]);
    nCols               = (mwIndex) mxGetScalar(prhs[1]);
    consideringCellsNo  = (mwSize) mxGetScalar(prhs[2]);
    
    mxArray0    = mexGetVariablePtr("caller","mexSortedIndicies");    
    mxArray1    = mexGetVariablePtr("caller","mexSDSNbrIndicies");    
    mxArray2    = mexGetVariablePtr("caller","n3IthNbrLinearIndicies");    
    mxArray3    = mexGetVariablePtr("caller","flood");
    mxArray4    = mexGetVariablePtr("caller","sedimentThick");
    mxArray5    = mexGetVariablePtr("caller","transportCapacityToNbrs");
    mxArray6    = mexGetVariablePtr("caller","sumTransportCapacityToNbrs");
    
    mexSortedIndicies           = mxGetPr(mxArray0);    
    mexSDSNbrIndicies           = mxGetPr(mxArray1);    
    n3IthNbrLinearIndicies      = mxGetPr(mxArray2);    
    flood                       = mxGetPr(mxArray3);    
    sedimentThick               = mxGetPr(mxArray4);    
    transportCapacityToNbrs     = mxGetPr(mxArray5);    
    sumTransportCapacityToNbrs  = mxGetPr(mxArray6);
    
    /* ��� ���� �ʱ�ȭ */
    plhs[0] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[1] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    plhs[2] = mxCreateDoubleMatrix(mRows,nCols,mxREAL);
    
    /* ��� ���� �ڷῡ �����͸� ���� */
    inputFlux           = mxGetPr(plhs[0]);
    outputFlux          = mxGetPr(plhs[1]);
    inputFloodedRegion  = mxGetPr(plhs[2]);
    
    /* ���� ��ƾ ���� */
    HillslopeProcessMex(
        inputFlux,
        outputFlux,
        inputFloodedRegion,
        mRows,
        nCols,
        consideringCellsNo,
        mexSortedIndicies,
        mexSDSNbrIndicies,
        n3IthNbrLinearIndicies,
        flood,
        sedimentThick,
        transportCapacityToNbrs,
        sumTransportCapacityToNbrs);
}

void HillslopeProcessMex(
    double * inputFlux,
    double * outputFlux,
    double * inputFloodedRegion,
    mwIndex mRows,
    mwIndex nCols,
    mwSize consideringCellsNo,
    double * mexSortedIndicies,
    double * mexSDSNbrIndicies,
    double * n3IthNbrLinearIndicies,
    double * flood,
    double * sedimentThick,
    double * transportCapacityToNbrs,
    double * sumTransportCapacityToNbrs)
{
    /* �ӽ� ���� ���� */
    const int FLOODED = 2; /* flooded region */
    mwSize ithNbr,ithCell;
    mwIndex ithCellIdx,toIthNbr,ithNbrIdx,outletIdx;
    double scale;    
            
    for (ithCell=0;ithCell<consideringCellsNo;ithCell++)
    {
        /* 1. i��° �� ���� */
        /* * ����: MATLAB �迭 ������ ���� '-1'�� ������ */
        ithCellIdx = (mwIndex) mexSortedIndicies[ithCell] - 1;

        /* 2. i��° ���� ������ �β��� ����� �̿� ������ ���� �̵� ������ �� */

        /* 1) ���� �̵��Ǵ� ���� �ʱ�ȭ */
        /* * ����: ��� ��鿡���� ���Է��� ����Ͽ� ���� �̵� ������ ����.
         *   ������ �Ϲ������� Ȯ�����󿡼��� �� ������� ��ηκ����� ������
         *   ����Ͽ� ���� ���� ������ ���� */
        scale = 1;
        
        /* 2) ����ۿ뿡 ���� �� ������ ��ݴɷ��� (��� ��鿡���� ��������
         *    �����) �� ������ �β����� ū ���� Ȯ���ϰ� �������� ������ */
        if (sumTransportCapacityToNbrs[ithCellIdx] > sedimentThick[ithCellIdx])
        {
            /* (1) ũ�ٸ�, ������ �β��� ������ */
            outputFlux[ithCellIdx] = sedimentThick[ithCellIdx];
            /* ���� ������ ������ */
            scale = sedimentThick[ithCellIdx] / sumTransportCapacityToNbrs[ithCellIdx];
        }
        else
        {
            /* (2) �۴ٸ�, ��ݴɷ� �״�� �� */
            outputFlux[ithCellIdx] = sumTransportCapacityToNbrs[ithCellIdx];
        }        
        
        /* 3. �� �̿� ���� �������� �������� ���� */
        for (ithNbr=0;ithNbr<8;ithNbr++)
        {
            /* 1) �� �̿� ������ ��ݴɷ��� ����Ű�� ���� ���� */
            /* * ����: ithCellIdx���� '-1'�� ���������Ƿ� �� �� �ʿ䰡 ���� */
            toIthNbr = ithCellIdx + ithNbr * (mRows*nCols);
            
            /* 2) i��° �̿� ������ ���ⷮ�� �ִ����� Ȯ���� */
            if (transportCapacityToNbrs[toIthNbr] > 0)
            {
                /* (1) i��° �̿� ������ ������ �ִ� ��� */

                /* A. 3���� �̿� �� ���� */
                /* * ����: MATLAB �迭 ������ ���� '-1'�� ������ */
                ithNbrIdx = (mwIndex) n3IthNbrLinearIndicies[toIthNbr] - 1;
                
                /* B. i��° �̿� ���� flooded region ������ Ȯ���� */
                if (flood[ithNbrIdx] == FLOODED)
                {

                    /* A) flooded region�� ���, inputFloodedRegion�� ��������
                     *    �������� ���� */

                    /* (A) flooded region ���ⱸ ���� */
                    /* * ����: MATLAB �迭 ������ ���� '-1'�� ������ */
                    outletIdx = (mwIndex) mexSDSNbrIndicies[ithNbrIdx] - 1;
                

                    /* (B) inputFloodedRegion �������� �������� ���� */
                    inputFloodedRegion[outletIdx] 
                        = inputFloodedRegion[outletIdx]
                        + scale * transportCapacityToNbrs[toIthNbr];
                }
                else
                {
                    /* B) flooded region�� �ƴ� ���, i��° �̿� ���� ��������
                     *    �������� ���� */
                    inputFlux[ithNbrIdx] = (inputFlux[ithNbrIdx]
                        + scale * transportCapacityToNbrs[toIthNbr]);
                } /* if (flood[ithNbrIdx] == FLOODED) */
            } /* if (transportCapacityToNbrs[toIthNbr] > 0) */
        } /* for (ithNbr=1 */
    } /* for (ithCell=0; */
} /* void HillslopeProcessMex */