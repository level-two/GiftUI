#ifndef GIFTUI_RESEARCH_H
#define GIFTUI_RESEARCH_H
#include <stdint.h>
#include <stddef.h>
struct giftui_static_host_storage;
uint32_t giftui_research_clock(void);
void giftui_research_stage(uint32_t, uint32_t);
void giftui_research_begin(uint32_t, uint32_t);
void giftui_research_end(uint32_t);
int giftui_research_write(uint16_t,uint16_t,uint16_t,uint16_t,const uint8_t *,size_t);
int giftui_research_service(const struct giftui_static_host_storage *, uint64_t);
void giftui_research_source(uint64_t);
void giftui_research_retired(uint32_t);
int giftui_research_run(void);
#endif
