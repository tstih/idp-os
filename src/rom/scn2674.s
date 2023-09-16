            ;; scn2674.s
            ;; 
            ;; scn2674  
            ;;
            ;; 2023-09-16   tstih
            .module scn2674

            ;; --- 0x34 - R/W:character register ------------------------------
            .equ SCN2674_CHR,               0x34


            ;; --- 0x35 - R/W:attribute register ------------------------------
            .equ SCN2674_AT,                0x35
            .equ SCN2674_AT_NONE,           0x00    ; no attributes
            .equ SCN2674_AT_BLINK,          0x01    ; blink
            .equ SCN2674_AT_UNDERLINE,      0x02    ; underline
            .equ SCN2674_AT_SPC_CHR,        0x04    ; special character
            .equ SCN2674_AT_PROTECT,        0x08    ; protect
            .equ SCN2674_AT_HIGHLIGHT,      0x10    ; R:highlight, W:red foreground
            .equ SCN2674_AT_REVERSE,        0x20    ; R:reverse, W:green background
            .equ SCN2674_AT_GP2,            0x40    ; R:GP 2, W:blue background
            .equ SCN2674_AT_GP1,            0x80    ; R:GP 1, W:red background


            ;; --- 0x36 - W:gr.scroll (byte value=scan lines), R:common input -
            .equ SCN2674_GR_SCROLL,         0x36

            .equ SCN2674_GR_CMNI,           0x36    ; same register, different name
            .equ SCN2674_GR_CMNI_SCN2674A,  0x10    ; SCN2674 access flag
            .equ SCN2674_GR_CMNI_PIX,       0x80    ; graph. pix input


            ;; --- 0x38 - W:init (all 15 init reg. sequentially accessed) -----
            ;; R:interrupt (bits 7-6 default 0)
            .equ SCN2674_INIT,              0x38
            .equ SCN2674_IR,                0x38    ; same register, different name
            .equ SCN2674_IR_SS2,            0x01    ; split screen 2 interrupt
            .equ SCN2674_IR_RDY,            0x02    ; ready interrupt
            .equ SCN2674_IR_SS1,            0x04    ; split screen 1 interrupt
            .equ SCN2674_IR_LZ,             0x08    ; line zero interrupt
            .equ SCN2674_IR_VB,             0x10    ; vblank int


            ;; --- 0x39 - W:command (byte is command) -------------------------
            ;; R:status (bits 7-5 default 0)
            .equ SCN2674_CMD,               0x39    
            .equ SCN2674_CMD_RESET,         0x00    ; master reset
            .equ SCN2674_CMD_SET_IR,        0x10    ; set IR pointer to lower nibble
            .equ SCN2674_CMD_CURS_OFF,      0x30    ; switch off cursor
            .equ SCN2674_CMD_CURS_ON,       0x31    ; switch on cursor
            .equ SCN2674_CMD_WC2P,          0xbb    ; write from cursor to pointer
            .equ SCN2674_CMD_WAC,           0xab    ; write at cursor
            .equ SCN2674_CMD_WAC_NO_MOVE,   0xaa    ; write at cur, don't move cur
            .equ SCN2674_CMD_RAC,           0xac    ; read at cursor
            .equ SCN2674_CMD_RDPTR,         0xA4    ; read at pointer


            .equ SCN2674_STS,               0x39    ; same register, different name    
            .equ SCN2674_STS_SS2,           0x01    ; split screen 2 interrupt
            .equ SCN2674_STS_RDYI,          0x02    ; ready interrupt
            .equ SCN2674_STS_SS1,           0x04    ; split screen 1 interrupt
            .equ SCN2674_STS_LZ,            0x08    ; line zero interrupt
            .equ SCN2674_STS_VB,            0x10    ; vblank int
            .equ SCN2674_STS_RDY,           0x20    ; ready flag


            ;; --- 0x3a - R/W: screen start 1 lower register ------------------
            .equ SCN2674_SS1_LO,            0x3a
            ;; --- 0x3b - R/W: screen start 1 upper register ------------------
            .equ SCN2674_SS1_HI,            0x3b


            ;; --- 0x3c - R/W: cursor address lower register ------------------
            .equ SCN2674_CUR_LO,            0x3c
            ;; --- 0x3d - R/W: cursor address upper register ------------------
            .equ SCN2674_CUR_HI,            0x3d


            ;; --- 0x3e - R/W: screen start 2 lower register ------------------
            .equ SCN2674_SS2_LO,            0x3e
            ;; --- 0x3f - R/W: screen start 2 upper register ------------------
            .equ SCN2674_SS2_HI,            0x3f


            .area   _CODE
            ;; ----------------------------------------------------------------
            ;; <hl> *next_dev_s_addr <- scn2674_probe(<hl> *dev_s_addr);
            ;; ----------------------------------------------------------------
            ;; this routine initializes (and detects) the SCN2674 chip. 
            ;; if detected it creates a device entry for it (see: struct 
            ;; dev_s) in space pointed by the HL register and increases the
            ;; register to point to the first free byte after the structure.
            ;; 
            ;; input(s):    
            ;;  hl  ... pointer to space for device structure if detected.
            ;; output(s):   
            ;;  hl  ... points to next slot for dev_s, same as input if no
            ;;          device has been detected
            ;; destroys:
            ;;  a. bc, hl
            ;; ----------------------------------------------------------------
scn2674_probe::
            ;; tech. doc. - master reset 
            ;; must be called twice upon power up.
            ;; no delay is required (should we have one?)
            ld      a,#SCN2674_CMD_RESET
            out     (#SCN2674_CMD),a
            out     (#SCN2674_CMD),a
            ;; set SS1 and SS2
            out     (SCN2674_SS1_LO),a
            out     (SCN2674_SS1_HI),a
            out     (SCN2674_SS2_LO),a
            out     (SCN2674_SS2_HI),a
            ;; sent init sequence
            ld      hl,#scn2674_init_seq
            ld      c,#SCN2674_INIT
            ld      b,#escn2674_init_seq-#scn2674_init_seq
            otir
            ret

scn2674_init_seq:
            .db     0x10, 0x20, 0x30
escn2674_init_seq: