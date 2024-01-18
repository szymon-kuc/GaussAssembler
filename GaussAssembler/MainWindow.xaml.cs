using System;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using System.Diagnostics;

namespace GaussEliminationApp
{
    public partial class Form1 : Form
    {
        [DllImport(@"C:\Users\Vikus\source\repos\GaussAssembler\x64\Debug\Gauss.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern void GaussEliminate(int[] matrix);

        private TextBox[] inputBoxes = new TextBox[9];
        private Label[] resultLabels = new Label[9];
        private Button btnCalculate;
        private ComboBox methodSelector; // Nowa kontrolka do wyboru metody

        public Form1()
        {
            InitializeForm(); // inicializacja GUI
        }

        private void InitializeForm()
        {   
            //petla do wyswitlanie pol teksotwych do podania liczby macierzy 
            for (int i = 0; i < 9; i++)
            {
                inputBoxes[i] = new TextBox();
                inputBoxes[i].Location = new System.Drawing.Point(10 + (i % 3) * 60, 10 + (i / 3) * 30);
                inputBoxes[i].Size = new System.Drawing.Size(50, 20);
                this.Controls.Add(inputBoxes[i]);
            }

            //przycisk do urchomienia obliczeń

            btnCalculate = new Button();
            btnCalculate.Text = "Oblicz";
            btnCalculate.Location = new System.Drawing.Point(10, 130);
            btnCalculate.Click += new EventHandler(btnCalculate_Click);// odwłoanie do funkcji która sie wykonuje po 'click'
            this.Controls.Add(btnCalculate);

            //petla wypisujaca pola do wyników
           for (int i = 0; i < 9; i++)
            {
                resultLabels[i] = new Label();
                resultLabels[i].Location = new System.Drawing.Point(10 + (i % 3) * 60, 160 + (i / 3) * 30);
                resultLabels[i].Size = new System.Drawing.Size(50, 20);
                this.Controls.Add(resultLabels[i]);
            }

            this.AutoSize = true;
            this.AutoSizeMode = AutoSizeMode.GrowAndShrink;

            // Inicjalizacja wyboru metody
            methodSelector = new ComboBox();
            methodSelector.Items.AddRange(new string[] { "Metoda Asemblera", "Metoda C#" });
            methodSelector.SelectedIndex = 0;
            methodSelector.Location = new System.Drawing.Point(10, 100);
            this.Controls.Add(methodSelector);
        }

        private void btnCalculate_Click(object sender, EventArgs e)
        {
            int[,] matrix = new int[3, 3];//definicja zmiennej macierzy

            try
            {
                for (int i = 0; i < 9; i++)
                {
                    matrix[i / 3, i % 3] = Convert.ToInt32(inputBoxes[i].Text); //konwersja do INT
                }

                if (methodSelector.SelectedIndex == 0)
                {
                    //metoda assembler
                    int[] flatMatrix = new int[9];
                    for (int i = 0; i < 9; i++)
                        flatMatrix[i] = matrix[i / 3, i % 3];
                    Stopwatch stopwatch = new Stopwatch();
                    stopwatch.Start(); // Rozpocznij mierzenie czasu

                    GaussEliminate(flatMatrix); // Funkcja jezyka assemberl do wyliczenia macierzy

                    stopwatch.Stop(); // Zatrzymaj mierzenie czasu
                    MessageBox.Show("Czas wykonania: " + stopwatch.ElapsedMilliseconds + " ms");

                    for (int i = 0; i < 9; i++)
                        matrix[i / 3, i % 3] = flatMatrix[i]; 
                }
                else
                { 

                    //c# metoda
                    Stopwatch stopwatch2 = new Stopwatch();
                    stopwatch2.Start(); // Rozpocznij mierzenie czasu

                    Eliminate(matrix);

                    stopwatch2.Stop(); // Zatrzymaj mierzenie czasu
                    MessageBox.Show("Czas wykonania: " + stopwatch2.ElapsedMilliseconds + " ms");
                }
                //wypisanie wyniku
                for (int i = 0; i < 9; i++)
                {
                    resultLabels[i].Text = matrix[i / 3, i % 3].ToString();
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
                    float factor = (float)matrix[row, pivot] / matrix[pivot, pivot];
                    for (int col = pivot; col < colCount; col++)
                    {
                        matrix[row, col] -= (int)(factor * matrix[pivot, col]);
                    }
                }
            }
        }
    }
}
