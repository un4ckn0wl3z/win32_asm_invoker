.code

externdef CreateFileA:proc					; import CreateFileA
externdef WriteFile:proc					; import WriteFile
externdef CloseHandle:proc					; import CloseHandle
externdef GetLastError:proc					; import GetLastError

OPEN_ALWAYS = 4								; prepare data for CreateFileA API
GENERIC_WRITE = 40000000h					; prepare data for CreateFileA API

main proc									; entry point
	push rbx								; save non-volatile register
	push rbp								; prolog
	mov rbp, rsp
	lea rcx, filename						; load address of 'filename' into 'rcx'
	mov edx, GENERIC_WRITE					; mov GENERIC_WRITE value into 'edx'
	xor r8d, r8d							; zeroed r8d
	xor r9d, r9d							; zeroed r9d
	push 0									; push extra parameters onto stack
	push 0									; push extra parameters onto stack
	push OPEN_ALWAYS						; push extra parameters onto stack
	sub rsp, 20h							; preserve spill stack space for 32 bytes
	call CreateFileA						; call CreateFileA
	test eax, eax							; error check
	jz error								; jump to error label

	mov rcx, rax							; prepare parameter for call next API
	lea rdx, text							; load address of 'text' into 'rdx'
	mov r8, sizeof text						; load text size into 'r8'
	lea r9, written							; load address of 'written' into 'r9'
	mov rbx, rcx							; backup HANDLE (rcx) into rbx
	push 0									; push extra parameters onto stack
	and rsp, -16							; force alignment stack for 16-bytes
	call WriteFile							; call WriteFile
	test eax, eax							; error check
	jz error								; jump to error label

	mov rcx, rbx							; restore HANDLE (rbx) into rcx
	call CloseHandle						; call CloseHandle
	test eax, eax							; error check
	jz error								; jump to error label
	mov rsp, rbp							; epilog
	pop rbp
	pop rbx									; restore non-volatile register
	ret										; return back

error:										; error label
	call GetLastError						; call GetLastError
	mov rsp, rbp							; epilog
	pop rbp
	pop rbx									; restore non-volatile register
	ret										; return back

main endp									; exit point

.data

filename db "C:\temp\test_file.txt",0		
text db "Write from ASM!"
written db ?

end