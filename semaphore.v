module Semaphore #(
    parameter CLK_FREQ = 100_000_000
) (
    input wire clk,
    input wire rst_n,

    input wire pedestrian,

    output wire green,
    output wire yellow,
    output wire red
);

reg [29:0] contador;
reg [2:0] estado_atual;

assign red    = estado_atual[2];
assign green  = estado_atual[1];
assign yellow = estado_atual[0];


localparam [2:0] VERMELHO = 3'b100,
                 VERDE    = 3'b010,
                 AMARELO  = 3'b001;


localparam integer CICLOS_AMARELO  = (CLK_FREQ * 0.5) - 1;   // 0,5 s
localparam integer CICLOS_VERMELHO = (CLK_FREQ * 5) - 1;  // 7 s
localparam integer CICLOS_VERDE    = (CLK_FREQ * 7) - 1;  // 5 s

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        estado_atual <= VERMELHO;
        contador <= 0;
    end else begin
        case (estado_atual)
            VERMELHO: begin
                if (contador >= CICLOS_VERMELHO) begin
                    estado_atual <= VERDE;
                    contador <= 0;
                end else begin
                    contador <= contador + 1;
                end
            end
            VERDE: begin
                if (pedestrian || contador >= CICLOS_VERDE) begin
                    estado_atual <= AMARELO;
                    contador <= 0;
                end else begin
                    contador <= contador + 1;
                end
            end
            AMARELO: begin
                if (contador >= CICLOS_AMARELO) begin
                    estado_atual <= VERMELHO;
                    contador <= 0;
                end else begin
                    contador <= contador + 1;
                end
            end
            default: begin
                estado_atual <= VERMELHO;
                contador <= 0;
            end
        endcase
    end
end

endmodule
