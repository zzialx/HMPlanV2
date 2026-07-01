import { navApi } from "../../common/api/NavApi"

export class WinNavVM {
  async getAppNav(): Promise<boolean> {
    try {
      const apiRes = await navApi();

      return true
    }catch (e) {
      return false
    }
	}

}