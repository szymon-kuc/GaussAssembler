using System;
using System.Runtime.InteropServices;

class GaussElimination
{
    [DllImport(@"E:\Studia\JA\GaussAssembler\x64\Debug\Gauss.dll", CallingConvention = CallingConvention.Cdecl)]
    public static extern void GaussEliminate(int[] matrix);

    static void Main()
    {
        int[] matrix = new int[] {
            1, 2, 3,
            4, 5, 6,
            7, 8, 9
        };

        int[,] matrix2 = {
            { 1, 2, 3 },
            { 4, 5, 6 },
            { 7, 8, 9 }
        };

        GaussEliminate(matrix);

        // Wyświetlenie zmodyfikowanej macierzy
        for (int i = 0; i < 3; i++)
        {
            for (int j = 0; j < 3; j++)
            {
                Console.Write(matrix[i * 3 + j] + " ");
            }
            Console.WriteLine();
        }


        Eliminate(matrix2);

        PrintMatrix(matrix2);
    }

    static void Eliminate(int[,] matrix)
    {
        int rowCount = matrix.GetLength(0);
        int colCount = matrix.GetLength(1);

        for (int pivot = 0; pivot < rowCount - 1; pivot++)
        {
            for (int row = pivot + 1; row < rowCount; row++)
            {
                float factor = (float)matrix[row, pivot] / matrix[pivot, pivot];

                for (int col = pivot; col < colCount; col++)
                {
                    matrix[row, col] -= (int)(factor * matrix[pivot, col]);
                }
            }
        }
    }

    static void PrintMatrix(int[,] matrix)
    {
        int rowCount = matrix.GetLength(0);
        int colCount = matrix.GetLength(1);

        for (int i = 0; i < rowCount; i++)
        {
            for (int j = 0; j < colCount; j++)
            {
                Console.Write(matrix[i, j] + "\t");
            }
            Console.WriteLine();
        }
    }
}
