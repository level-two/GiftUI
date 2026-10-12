/* Statically resolved Embedded Swift runtime-function references; no startup copy. */
. = ALIGN(4);
__giftui_counter_got_start = .;
*(.got.plt)
*(.igot.plt)
*(.got)
*(.igot)
__giftui_counter_got_end = .;
