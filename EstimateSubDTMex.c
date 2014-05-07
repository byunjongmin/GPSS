/*
 * EstimateSubDTMex.c
 *
 *  (���� ���� ������) �Ϸ����� ������ ��簡 0�� �Ǵ� �ð��� �����ϴ� �Լ�
 *  EstimateSubDT �Լ�(ver 0.8)�� for �ݺ������� mex ���Ϸ� ������
 % 
 * takenTime ...                0 �Ϸ����� ������ ��簡 0�� �Ǵ� �ð� [s]
 * = EstimateSubDTMex ...
 * (mRows ...                   0 . �� ����
 * ,nCols ...                   1 . �� ����
 * ,consideringCellsNo)         2 . ��õ�ۿ��� �߻��ϴ� �� ��
 *----------------------------- mexGetVariablePtr �Լ��� �����ϴ� ����
 * mexSortedIndicies ...        3 . �������� ���ĵ� ����
 * e1LinearIndicies ...         4 . ���� �� ����
 * e2LinearIndicies ...         5 . ���� �� ����
 * outputFluxRatioToE1 ...      6 . ���� ������ ���� ����
 * outputFluxRatioToE2 ...      7 . ���� ������ ���� ����
 * mexSDSNbrIndicies ...        8 . ���� �� ����
 * floodedRegionCellsNo ...     9 . flooded region ���� �� ��
 * dElev ...                    10 . �� ��ȭ�� [m/trialTime]
 * elev ...                     11 . �� [m]
 *----------------------------- mexGetVariable �Լ��� �����ؿ��� ����
 * takenTime ...                0 . inf�� �ʱ�ȭ�� ��� ����
 *
 */

# include "mex.h"
# include "matrix.h"

/* computational routine */
void EstimateSubDTMex(
    double * takenTime,
    mwSize consideringCellsNo,
    double * mexSortedIndicies,
    double * e1LinearIndicies,
    double * e2LinearIndicies,
    double * outputFluxRatioToE1,
    double * outputFluxRatioToE2,
    double * mexSDSNbrIndicies,
    double * floodedRegionCellsNo,
    double * dElev,
    double * elev);

/* Gateway Function */
void mexFunction(int nlhs,       mxArray * plhs[]
                ,int nrhs, const mxArray * prhs[])
{
    /* check for proper number of arguments */
    /* validate the input values */
    
    /* variable declaration */
    /* input variable declaration */
    mwSize mRows;
    mwSize nCols;
    mwSize consideringCellsNo;
    /* ����: mxArray �ڷ��� ������ mexGetVariablePtr �Լ��� �̿��Ͽ�
     * ȣ���Լ��� �۾������� �ִ� �������� �����͸� �ҷ��� */
    const mxArray * mxArray3;
    const mxArray * mxArray4;
    const mxArray * mxArray5;
    const mxArray * mxArray6;
    const mxArray * mxArray7;
    const mxArray * mxArray8;
    const mxArray * mxArray9;
    const mxArray * mxArray10;
    const mxArray * mxArray11;
    double * mexSortedIndicies;
    double * e1LinearIndicies;
    double * e2LinearIndicies;
    double * outputFluxRatioToE1;
    double * outputFluxRatioToE2;
    double * mexSDSNbrIndicies;
    double * floodedRegionCellsNo;
    double * dElev;
    double * elev;
    
    /* output variable declaration */
    double * takenTime;
            
    /* create a pointer to the real data in the input matrix */
    mRows               = (mwSize) mxGetScalar(prhs[0]);
    nCols               = (mwSize) mxGetScalar(prhs[1]);
    consideringCellsNo  = (mwSize) mxGetScalar(prhs[2]);
    
    mxArray3  = mexGetVariablePtr("caller","mexSortedIndicies");    
    mxArray4  = mexGetVariablePtr("caller","e1LinearIndicies");    
    mxArray5  = mexGetVariablePtr("caller","e2LinearIndicies");    
    mxArray6  = mexGetVariablePtr("caller","outputFluxRatioToE1");
    mxArray7  = mexGetVariablePtr("caller","outputFluxRatioToE2");
    mxArray8  = mexGetVariablePtr("caller","mexSDSNbrIndicies");
    mxArray9  = mexGetVariablePtr("caller","floodedRegionCellsNo");
    mxArray10 = mexGetVariablePtr("caller","dElev");
    mxArray11 = mexGetVariablePtr("caller","elev");
    
    mexSortedIndicies      = mxGetPr(mxArray3);    
    e1LinearIndicies       = mxGetPr(mxArray4);    
    e2LinearIndicies       = mxGetPr(mxArray5);    
    outputFluxRatioToE1    = mxGetPr(mxArray6);    
    outputFluxRatioToE2    = mxGetPr(mxArray7);    
    mexSDSNbrIndicies      = mxGetPr(mxArray8);    
    floodedRegionCellsNo   = mxGetPr(mxArray9);    
    dElev                  = mxGetPr(mxArray10);
    elev                   = mxGetPr(mxArray11);
    
    /* prepare output data */
    /* create the output matrix */
    plhs[0] = mexGetVariable("caller","takenTime");
    
    /* get a pointer to the real data in the output matrix */
    takenTime = mxGetPr(plhs[0]);
    
    /* call the computational routine */
    EstimateSubDTMex(
        takenTime,
        consideringCellsNo,
        mexSortedIndicies,
        e1LinearIndicies,
        e2LinearIndicies,
        outputFluxRatioToE1,
        outputFluxRatioToE2,
        mexSDSNbrIndicies,
        floodedRegionCellsNo,
        dElev,
        elev);

}

void EstimateSubDTMex(
    double * takenTime,
    mwSize consideringCellsNo,
    double * mexSortedIndicies,
    double * e1LinearIndicies,
    double * e2LinearIndicies,
    double * outputFluxRatioToE1,
    double * outputFluxRatioToE2,
    double * mexSDSNbrIndicies,
    double * floodedRegionCellsNo,
    double * dElev,
    double * elev)
{
    /* �ӽ� ���� ���� */
    mwIndex ithCell,ithCellIdx,e1,e2,next;
    
    double inf;
    double takenTimeForE1,takenTimeForE2;
    
    /* takenTimeForE1, takenTimeForE2 ���� �ʱ�ȭ */
    inf = mxGetInf();
    takenTimeForE1 = inf;
    takenTimeForE2 = inf;
    
    /* (���� ���� ������) ���� ������ ��簡 0�� �Ǵ� �ð��� ������ */
    for (ithCell=0;ithCell<consideringCellsNo;ithCell++)
    {
        /* 1. i��° �� ����
         * * ����: MATLAB �迭 ������ ���� '-1'�� ������ */
        ithCellIdx = (mwIndex) mexSortedIndicies[ithCell] - 1;

        /* 2. i��° ���� ���ⱸ���� Ȯ���� */
        if ((int) floodedRegionCellsNo[ithCellIdx] == 0)
        {
            /* 1) ���ⱸ�� �ƴ϶��, i��° ���� �� ��ȭ���� ���� ������ ����
             *    ���� ������ �� ��ȭ���� ����
             * * ����: ���� ����(e1,e2)�� ħ������ �� ���� ���, trialTime����
             *   ����� �Ϸ��� �⺹�� ������. ���� �⺹ ������ �߻��ϱ�
             *   ���������� �ð�, �� ���� ����(e1,e2)���� ��簡 0�� �Ǵµ�
             *   �ɸ��� �ð�[trialTime]�� ���ϰ� �̸� ���߿� ���� �����ð�����
             *   ������.
             * * ����: ���� ������ �帧 ������ ��� 0.0000001 ���ٴ� ū
             *   ��쿡�� �ð��� ����. e1 �Ǵ� e2 �� �� ���θ� �帧��
             *   ���޵Ǵ��� ��ȿ���� �Ѱ�� ���� �帧 ������ ��Ȯ�ϰ� 1 �Ǵ�
             *   0�� ���� �ʱ� ������. �� ��� 0.0000001 ���� Ŭ ��쿡��
             *   ��쿡�� �帧�� ���޵ȴٰ� ������. ���� �̺��� ���� ��쿡��
             *   ������ ���ʿ��� */
            
            /* (1) ���� �� ���� */
            /* * ����: MATLAB �迭 ������ ���� '-1'�� ������ */
            e1 = (mwIndex) e1LinearIndicies[ithCellIdx] - 1;
            e2 = (mwIndex) e2LinearIndicies[ithCellIdx] - 1;

            /* (2) i��° ���� �� ��ȭ���� e1�� �� ��ȭ������ ���ٸ�, ����
             *     ���� ������ ��簡 0�� �Ǵµ� �ɸ��� �ð��� ����
             * * ����: takenTimeForX�� ���ڴ� �׻� ���� ���� ���� ���� if
             *   ���ǹ��� ���� ��� �и� ���� ���� ���� �����Ƿ� ��ü�� �׻�
             *   ���� ���� ���� */            
            if ((dElev[ithCellIdx] < dElev[e1])
                && (outputFluxRatioToE1[ithCellIdx] > 0.0000001))
            {
                takenTimeForE1 = (elev[e1] - elev[ithCellIdx])
                    / (dElev[ithCellIdx] - dElev[e1]);
            }            

            /* (3) i��° ���� �� ��ȭ���� e2�� �� ��ȭ������ ���ٸ�, ����
             *     ������ ��簡 0�� �Ǵµ� �ɸ��� �ð��� ���� */
            if ((dElev[ithCellIdx] < dElev[e2])
                && (outputFluxRatioToE2[ithCellIdx] > 0.0000001))
            {
                takenTimeForE2 = (elev[e2] - elev[ithCellIdx])
                    / (dElev[ithCellIdx] - dElev[e2]);
            }

            /* (4) e1�� e2�� �ҿ� �ð��� ���� ���� ���� �ҿ� �ð����� ����� */
            if (takenTimeForE1 <= takenTimeForE2)
            {
                    takenTime[ithCellIdx] = takenTimeForE1;
            }
            else
            {                    
                    takenTime[ithCellIdx] = takenTimeForE2;
            }
            
            /* (5) takenTimeForE1, takenTimeForE2 ���� �ʱ�ȭ */
            takenTimeForE1 = inf;
            takenTimeForE2 = inf;
        }
        else /* (int) floodedRegionCellsNo[ithCellIdx] != 0 */
        {
            /* 2) ���ⱸ�� ��쿡�� i��° ���� �� ��ȭ���� �ִ��Ϻΰ��
             *    ������ ���� ���� ���� �� ��ȭ���� ���� */
            
            /* (1) ���� �� ����
             * * ����: MATLAB �迭 ������ ���� '-1'�� ������ */
            next = (mwIndex) mexSDSNbrIndicies[ithCellIdx] - 1;
    
            /* (2) i��° ���� �� ��ȭ���� ���� ���� �� ��ȭ������ �۴ٸ�
             *     �۴ٸ� ���� ������ ��簡 0�� �Ǵµ� �ɸ��� �ð��� ���� */
            if (dElev[ithCellIdx] < dElev[next])
            {
                takenTime[ithCellIdx] = (elev[next] - elev[ithCellIdx])
                    / (dElev[ithCellIdx] - dElev[next]);
            }

        } /* (int) floodedRegionCellsNo[ithCellIdx] == 0 */
    } /* for (ithCell=0 */
} /* void EstimateDElevByFluvialProcess( */