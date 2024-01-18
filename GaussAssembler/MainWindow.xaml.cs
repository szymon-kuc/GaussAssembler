using System.Runtime.InteropServices;
using System.Diagnostics;
using System.Numerics;
using System;
using System.Linq;
using System.Windows.Forms;

namespace GaussEliminationApp
{
    public partial class Form1 : Form
    {
        //SCIERZKI DO DLL NIE RUSZAĆ NIE ZMIENIAĆ :)
        //Wiktor-PC D:\STUDIA\ja\gauss\x64\Debug
        //Wiktor-laptop C:\Users\Vikus\source\repos\GaussAssembler\x64\Debug\


        [DllImport(@"D:\STUDIA\ja\gauss\x64\Debug\Gauss.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern void GaussEliminate(int[] matrix, int columns, int rows);

        private TextBox[,] inputBoxes;
        private Label[,] resultLabels;
        private Button btnCalculate;
        private ComboBox methodSelector; // Nowa kontrolka do wyboru metody
        private ComboBox matrixSizeSelector;

        public Form1() 
        {
            InitializeForm(); // inicializacja GUI
        }
         
        private void InitializeForm()
        {
            matrixSizeSelector = new ComboBox
            {
                Items = { "2x2", "3x3", "4x4" },
                SelectedIndex = 0,
                Location = new System.Drawing.Point(10, 10)
            };
            matrixSizeSelector.SelectedIndexChanged += MatrixSizeSelector_SelectedIndexChanged;
            this.Controls.Add(matrixSizeSelector);

            CreateTextBoxes();

                  //przycisk do urchomienia obliczeń
            btnCalculate = new Button
            {
                Text = "Oblicz",
                Location = new System.Drawing.Point(10, 220)
            };
            btnCalculate.Click += btnCalculate_Click; //odwołanie do funkcji on click 
            this.Controls.Add(btnCalculate);

            this.AutoSize = true;
            this.AutoSizeMode = AutoSizeMode.GrowAndShrink;

            methodSelector = new ComboBox
            {
                Items = { "Metoda Asemblera", "Metoda C#" },
                SelectedIndex = 0,
                Location = new System.Drawing.Point(10, 160)
            };
            this.Controls.Add(methodSelector);
        }
        private void MatrixSizeSelector_SelectedIndexChanged(object sender, EventArgs e)
        {
            CreateTextBoxes();
            ResetResults();
        }
        private void ResetResults()
        {
            int selectedSize = matrixSizeSelector.SelectedIndex + 2;

            // Check if resultLabels is not null and has the same dimensions as selectedSize
            if (resultLabels != null && resultLabels.GetLength(0) == selectedSize && resultLabels.GetLength(1) == selectedSize + 1)
            {
                for (int i = 0; i < selectedSize; i++)
                {
                    for (int j = 0; j < selectedSize + 1; j++)
                    {
                        resultLabels[i, j].Text = "";
                        resultLabels[i, j].Hide();
                    }
                }
            }
        }
        private void CreateTextBoxes()
        {
            foreach (var control in this.Controls.OfType<TextBox>().ToArray())
            {
                this.Controls.Remove(control);
            }

            foreach (var control in this.Controls.OfType<Label>().ToArray())
            {
                this.Controls.Remove(control);
            }


            int selectedSize = matrixSizeSelector.SelectedIndex + 2;

            inputBoxes = new TextBox[selectedSize, selectedSize + 1];
            resultLabels = new Label[selectedSize, selectedSize + 1];

            for (int i = 0; i < selectedSize; i++)
            {
                for (int j = 0; j < selectedSize + 1; j++)
                {
                    inputBoxes[i, j] = new TextBox
                    {
                        Location = new System.Drawing.Point(10 + j * 60, 40 + i * 30),
                        Size = new System.Drawing.Size(50, 20)
                    };
                    this.Controls.Add(inputBoxes[i, j]);

                    resultLabels[i, j] = new Label
                    {
                        Location = new System.Drawing.Point(10 + (selectedSize + 1) * 60 + j * 60, 40 + i * 30),
                        Size = new System.Drawing.Size(50, 20),
                        Text = "",
                        TextAlign = ContentAlignment.MiddleCenter
                    };
                    this.Controls.Add(resultLabels[i, j]);
                }
            }
        }
        private void btnCalculate_Click(object sender, EventArgs e)
        {
            try
            {
                int selectedSize = matrixSizeSelector.SelectedIndex + 2;
                int[,] matrix = new int[selectedSize, selectedSize + 1];

                for (int i = 0; i < selectedSize; i++)
                {
                    for (int j = 0; j < selectedSize + 1; j++)
                    {
                        matrix[i, j] = Convert.ToInt32(inputBoxes[i, j].Text);
                    }
                }

                if (methodSelector.SelectedIndex == 0)
                {
                    int[] flatMatrix = new int[selectedSize * (selectedSize + 1)];
                    for (int i = 0; i < selectedSize; i++)
                    {
                        for (int j = 0; j < selectedSize + 1; j++)
                        {
                            flatMatrix[i * (selectedSize + 1) + j] = matrix[i, j];
                        }
                    }

                    Stopwatch stopwatch = new Stopwatch();
                    stopwatch.Start();

                    GaussEliminate(flatMatrix , selectedSize , selectedSize + 1);

                    stopwatch.Stop();
                    MessageBox.Show("Czas wykonania: " + stopwatch.ElapsedMilliseconds + " ms");

                    for (int i = 0; i < selectedSize; i++)
                    {
                        for (int j = 0; j < selectedSize + 1; j++)
                        {
                            matrix[i, j] = flatMatrix[i * (selectedSize + 1) + j];
                        }
                    }
                }
                else
                {
                    Debug.WriteLine("Using C# method");
                    Stopwatch stopwatch2 = new Stopwatch();
                    stopwatch2.Start();

                    Eliminate(matrix);

                    stopwatch2.Stop();
                    MessageBox.Show("Czas wykonania: " + stopwatch2.ElapsedMilliseconds + " ms");
                }

                // Debugging: Print the matrix after elimination
                Debug.WriteLine("Matrix after elimination:");
                for (int i = 0; i < selectedSize; i++)
                {
                    for (int j = 0; j < selectedSize + 1; j++)
                    {
                        Debug.Write(matrix[i, j] + "\t");
                    }
                    Debug.WriteLine("");
                }

                // wypisanie wyniku
                for (int i = 0; i < selectedSize; i++)
                {
                    for (int j = 0; j < selectedSize + 1; j++)
                    { 
                        resultLabels[i, j].Text = matrix[i, j].ToString();
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message);
            }
        }


        //funkcja rozwiazania macierzy w c# 
        static void Eliminate(int[,] matrix)
        {
            int rowCount = matrix.GetLength(0);
            int colCount = matrix.GetLength(1);
            for (int pivot = 0; pivot < rowCount - 1; pivot++)
            {
                for (int row = pivot + 1; row < rowCount; row++)
                {
                    double factor = (double)matrix[row, pivot] / matrix[pivot, pivot];
                    for (int col = pivot; col < colCount; col++)
                    {
                        matrix[row, col] -= (int)(factor * matrix[pivot, col]);
                    }
                }
            }
        }
    }
}
