/* Disposable connected research, fixed storage and actual production stage bodies. */
#include "research.h"
#include "production_host.h"
#include "static_host_storage.h"
#include "spi_tft.h"
#include "giftui_fault.h"
#include <errno.h>
#include <zephyr/kernel.h>
#include <cmsis_core.h>
#ifndef RESEARCH_MODE
#define RESEARCH_MODE 0
#endif
extern uint32_t giftui_signal_analyzer_current_revision(void);
extern uint32_t giftui_signal_analyzer_acquisition_state(void);
extern uint32_t giftui_signal_analyzer_capture_count(void);
extern uint32_t giftui_signal_analyzer_visible_window(void);
extern uint32_t giftui_signal_analyzer_needs_presentation(void);
extern uint16_t giftui_signal_analyzer_input_pending_count(void);
extern int32_t giftui_signal_analyzer_input_admit(uint8_t,uint16_t,uint16_t,uint32_t,uint8_t);
extern uint32_t giftui_signal_analyzer_action_point(uint16_t);
extern uint32_t giftui_signal_analyzer_rehearsal_clear(void *,void *);
extern uint32_t giftui_signal_analyzer_rehearsal_maximum_diagnostic(void);
extern void giftui_research_fresh_input(void);
struct research_frame {
 uint32_t revision,initial,outcome,start_tick,end_tick,total_cycles,state,capture,window;
 uint32_t spi_calls,spi_bytes,spi_cycles,refusals,stages[11];
};
volatile struct {
 uint32_t magic,status,mode,cpu_hz,clock_hz,calibration_cycles,calibration_ticks,count;
 int32_t results[2];
 uint32_t retired_revision[2],retired_pending[2],retired_needs[2],retired_touch_valid[2];
 uint32_t ending_state[2],ending_capture[2],source_polls,first_source_lo,first_source_hi,last_source_lo,last_source_hi;
 uint32_t controls_failed,run_ordinal,reserved[3];
 struct research_frame frames[6];
} giftui_spike013_trace;
static uint32_t frame_start,run_ordinal,last_control=UINT32_MAX;
uint32_t giftui_research_clock(void) {return DWT->CYCCNT;}
void giftui_research_begin(uint32_t revision,uint32_t initial) {
 uint32_t i=giftui_spike013_trace.count;
 if(i>=6) {giftui_spike013_trace.status=99;return;}
 giftui_spike013_trace.frames[i].revision=revision;
 giftui_spike013_trace.frames[i].initial=initial;
 giftui_spike013_trace.frames[i].start_tick=k_cycle_get_32();
 frame_start=DWT->CYCCNT;
}
void giftui_research_stage(uint32_t index,uint32_t start) {
 if(giftui_spike013_trace.count<6 && index<11)
 giftui_spike013_trace.frames[giftui_spike013_trace.count].stages[index]+=DWT->CYCCNT-start;
}
void giftui_research_end(uint32_t outcome) {
 uint32_t i=giftui_spike013_trace.count;if(i>=6)return;
 volatile struct research_frame *f=&giftui_spike013_trace.frames[i];
 f->total_cycles=DWT->CYCCNT-frame_start; f->end_tick=k_cycle_get_32();f->outcome=outcome;
 f->state=giftui_signal_analyzer_acquisition_state();f->capture=giftui_signal_analyzer_capture_count();
 f->window=giftui_signal_analyzer_visible_window();giftui_spike013_trace.count=i+1;
}
int giftui_research_write(uint16_t x,uint16_t y,uint16_t w,uint16_t h,const uint8_t *bytes,size_t n) {
 uint32_t i=giftui_spike013_trace.count;if(i>=6)return -EOVERFLOW;
 volatile struct research_frame *f=&giftui_spike013_trace.frames[i];uint32_t start=DWT->CYCCNT;
 f->spi_calls++;
 if(RESEARCH_MODE==1 && run_ordinal==0 && i==1 && f->refusals==0) {
  f->refusals++;giftui_fault_record(GIFTUI_FAULT_DISPLAY_SPI,-EIO);f->spi_cycles+=DWT->CYCCNT-start;return -EIO;
 }
 int result=spi_tft_write_rgb565(x,y,w,h,bytes,n);
 if(result==0)f->spi_bytes+=n;
 f->spi_cycles+=DWT->CYCCNT-start;return result;
}
static int action(uint16_t code) {
 uint32_t point=giftui_signal_analyzer_action_point(code),rev=giftui_signal_analyzer_current_revision();
 if(point==0)return -EINVAL;
 return giftui_signal_analyzer_input_admit(0,point&65535,point>>16,rev,1)==255 &&
 giftui_signal_analyzer_input_admit(2,point&65535,point>>16,rev,0)==255 ? 0 : -EIO;
}
int giftui_research_service(const struct giftui_static_host_storage *r,uint64_t now) {
 (void)now;uint32_t count=giftui_spike013_trace.count;
 if((RESEARCH_MODE==0 && count>=6) || (RESEARCH_MODE==1 && run_ordinal==1))return 1;
 if(last_control==count)return 0;
 int result=0;
 if(count==1)result=action(0);
 if(RESEARCH_MODE==0) {
  if(count==3)result=action(1);
  if(count==4)result=giftui_signal_analyzer_rehearsal_clear(r->profile,r->capture)==1 ? 0 : -EIO;
  if(count==5)result=giftui_signal_analyzer_rehearsal_maximum_diagnostic()==1 ? 0 : -EIO;
 }
 last_control=count;if(result!=0){giftui_spike013_trace.controls_failed++;return -1;}return 0;
}
void giftui_research_source(uint64_t now) {
 if(giftui_spike013_trace.source_polls==0){giftui_spike013_trace.first_source_lo=(uint32_t)now;giftui_spike013_trace.first_source_hi=(uint32_t)(now>>32);}
 giftui_spike013_trace.source_polls++;giftui_spike013_trace.last_source_lo=(uint32_t)now;giftui_spike013_trace.last_source_hi=(uint32_t)(now>>32);
}
void giftui_research_retired(uint32_t touch_valid) {giftui_spike013_trace.retired_touch_valid[run_ordinal]=touch_valid;}
int giftui_research_run(void) {
 giftui_spike013_trace.magic=0x53503133;giftui_spike013_trace.status=1;giftui_spike013_trace.mode=RESEARCH_MODE;
 giftui_spike013_trace.cpu_hz=SystemCoreClock;giftui_spike013_trace.clock_hz=CONFIG_SYS_CLOCK_HW_CYCLES_PER_SEC;
 CoreDebug->DEMCR|=CoreDebug_DEMCR_TRCENA_Msk;DWT->CTRL|=DWT_CTRL_CYCCNTENA_Msk;__DSB();__ISB();
 uint32_t tick=k_cycle_get_32(),cycle=DWT->CYCCNT;k_busy_wait(100000);
 giftui_spike013_trace.calibration_cycles=DWT->CYCCNT-cycle;giftui_spike013_trace.calibration_ticks=k_cycle_get_32()-tick;
 for(run_ordinal=0;run_ordinal<(RESEARCH_MODE==1?2U:1U);run_ordinal++) {
  giftui_spike013_trace.run_ordinal=run_ordinal;last_control=UINT32_MAX;
  if(run_ordinal!=0)giftui_research_fresh_input();
  int result=giftui_production_host_run();giftui_spike013_trace.results[run_ordinal]=result;
  giftui_spike013_trace.retired_revision[run_ordinal]=giftui_signal_analyzer_current_revision();
  giftui_spike013_trace.retired_pending[run_ordinal]=giftui_signal_analyzer_input_pending_count();
  giftui_spike013_trace.retired_needs[run_ordinal]=giftui_signal_analyzer_needs_presentation();
  giftui_spike013_trace.ending_state[run_ordinal]=giftui_signal_analyzer_acquisition_state();
  giftui_spike013_trace.ending_capture[run_ordinal]=giftui_signal_analyzer_capture_count();
 }
 if(giftui_spike013_trace.status!=99)giftui_spike013_trace.status=2;
 while(1)k_sleep(K_MSEC(10));return 0;
}
