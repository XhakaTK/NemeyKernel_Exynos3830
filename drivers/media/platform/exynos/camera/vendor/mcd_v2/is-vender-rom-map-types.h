/* ROM calibration map types shared by the XXT V5 camera maps. */
#ifndef IS_VENDER_ROM_MAP_TYPES_H
#define IS_VENDER_ROM_MAP_TYPES_H

#include <linux/types.h>

#define EXTEND_OEM_CHECKSUM "oem_checksum_base_addr"
#define EXTEND_AE_CAL "ae_cal_data"
#define EXTEND_STANDARD_CAL "standard_cal_data"

struct rom_extend_cal_addr {
	char *name;
	void *data;
	struct rom_extend_cal_addr *next;
};

struct rom_ae_cal_data {
	int32_t		rom_header_main_ae_start_addr;
	int32_t		rom_header_main_ae_end_addr;
	int32_t		rom_ae_module_info_start_addr;
	int32_t		rom_ae_checksum_addr;
	int32_t		rom_ae_checksum_len;
};


struct is_vender_rom_addr {
	/* Set '-1' if not used */

/***** ROM Version Check Section *****/
	char			camera_module_es_version;
	char			cal_map_es_version;
	int32_t		rom_max_cal_size;

/***** HEADER Referenced Section ******/
	int32_t		rom_header_cal_data_start_addr;
	int32_t		rom_header_main_module_info_start_addr;
	int32_t		rom_header_cal_map_ver_start_addr;
	int32_t		rom_header_project_name_start_addr;
	int32_t		rom_header_module_id_addr;
	int32_t		rom_header_main_sensor_id_addr;

	int32_t		rom_header_sub_module_info_start_addr;
	int32_t		rom_header_sub_sensor_id_addr;

	int32_t		rom_header_main_header_start_addr;
	int32_t		rom_header_main_header_end_addr;
	int32_t		rom_header_main_oem_start_addr;
	int32_t		rom_header_main_oem_end_addr;
	int32_t		rom_header_main_awb_start_addr;
	int32_t		rom_header_main_awb_end_addr;
	int32_t		rom_header_main_shading_start_addr;
	int32_t		rom_header_main_shading_end_addr;
	int32_t		rom_header_main_sensor_cal_start_addr;
	int32_t		rom_header_main_sensor_cal_end_addr;
	int32_t		rom_header_dual_cal_start_addr;
	int32_t		rom_header_dual_cal_end_addr;
	int32_t		rom_header_pdaf_cal_start_addr;
	int32_t		rom_header_pdaf_cal_end_addr;

	int32_t		rom_header_sub_oem_start_addr;
	int32_t		rom_header_sub_oem_end_addr;
	int32_t		rom_header_sub_awb_start_addr;
	int32_t		rom_header_sub_awb_end_addr;
	int32_t		rom_header_sub_shading_start_addr;
	int32_t		rom_header_sub_shading_end_addr;

	int32_t		rom_header_main_mtf_data_addr;
	int32_t		rom_header_sub_mtf_data_addr;

	int32_t		rom_header_checksum_addr;
	int32_t		rom_header_checksum_len;

/***** OEM Referenced Section *****/
	int32_t		rom_oem_af_inf_position_addr;
	int32_t		rom_oem_af_macro_position_addr;
	int32_t		rom_oem_module_info_start_addr;
	int32_t		rom_oem_checksum_addr;
	int32_t		rom_oem_checksum_len;

/***** AWB Referenced section *****/
	int32_t		rom_awb_module_info_start_addr;
	int32_t		rom_awb_checksum_addr;
	int32_t		rom_awb_checksum_len;

/***** Shading Referenced section *****/
	int32_t		rom_shading_module_info_start_addr;
	int32_t		rom_shading_checksum_addr;
	int32_t		rom_shading_checksum_len;

/***** SENSOR CAL(CrossTalk Cal for Remosaic) Referenced section *****/
	int32_t		rom_sensor_cal_module_info_start_addr;
	int32_t		rom_sensor_cal_checksum_addr;
	int32_t		rom_sensor_cal_checksum_len;

/***** DUAL DATA Referenced section *****/
	int32_t		rom_dual_module_info_start_addr;
	int32_t		rom_dual_checksum_addr;
	int32_t		rom_dual_checksum_len;

/***** PDAF CAL Referenced section *****/
	int32_t		rom_pdaf_module_info_start_addr;
	int32_t		rom_pdaf_checksum_addr;
	int32_t		rom_pdaf_checksum_len;

/***** SUB OEM Referenced Section *****/
	int32_t		rom_sub_oem_af_inf_position_addr;
	int32_t		rom_sub_oem_af_macro_position_addr;
	int32_t		rom_sub_oem_module_info_start_addr;
	int32_t		rom_sub_oem_checksum_addr;
	int32_t		rom_sub_oem_checksum_len;

/***** SUB AWB Referenced section *****/
	int32_t		rom_sub_awb_module_info_start_addr;
	int32_t		rom_sub_awb_checksum_addr;
	int32_t		rom_sub_awb_checksum_len;

/***** SUB Shading Referenced section *****/
	int32_t		rom_sub_shading_module_info_start_addr;
	int32_t		rom_sub_shading_checksum_addr;
	int32_t		rom_sub_shading_checksum_len;

/***** Dual Calibration Data2 *****/
	int32_t		rom_dual_cal_data2_start_addr;
	int32_t		rom_dual_cal_data2_size;
	int32_t		rom_dual_tilt_x_addr;
	int32_t		rom_dual_tilt_y_addr;
	int32_t		rom_dual_tilt_z_addr;
	int32_t		rom_dual_tilt_sx_addr;
	int32_t		rom_dual_tilt_sy_addr;
	int32_t		rom_dual_tilt_range_addr;
	int32_t		rom_dual_tilt_max_err_addr;
	int32_t		rom_dual_tilt_avg_err_addr;
	int32_t		rom_dual_tilt_dll_version_addr;
	int32_t		rom_dual_tilt_dll_model_id_addr;
	int32_t		rom_dual_tilt_dll_model_id_size;
	int32_t		rom_dual_shift_x_addr;
	int32_t		rom_dual_shift_y_addr;

/***** Extend Cal Data *****/
	const struct rom_extend_cal_addr		*extend_cal_addr;
};

#endif /* IS_VENDER_ROM_MAP_TYPES_H */
