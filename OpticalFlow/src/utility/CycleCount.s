	;module "Saturate"
	.arch Am2000
	.cpu SR
	.ifndef com.ambric.javac.__.in
	.define com.ambric.javac.__.in 1
	.inchannel in
	.endif
	.ifndef com.ambric.javac.__.out
	.define com.ambric.javac.__.out 1
	.outchannel out
	.endif
.text ; 3 words in this segment
	.balign 4
	; trigger t = (_run)*
	; K2 SR
	.text
	.balign 2


k_entry:
	jump code_ptr(k_init)
	nop
k_init:
	ld 0
	mov prev, r2
k_star_0:
	;code here
	;call code_ptr(_run)
	
	inns in // Try a read from in
	brio BRIO_TAKEN // Branch if inns succeeded
	add_i r2, 1, r2 // Delay slot instruction always executed
	jump code_ptr(k_star_0)// Not executed if branch taken
	nop
BRIO_TAKEN:
	mov prev, sink, out, de0;write out the values
	mov r2, sink, out, de0;write the loop count
	jump code_ptr(k_init);start over
	nop
k_halt:
	trap 96
	