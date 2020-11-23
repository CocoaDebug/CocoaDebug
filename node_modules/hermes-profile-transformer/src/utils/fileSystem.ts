import { readFile } from 'fs';
import { promisify } from 'util';

export const readFileAsync = async (path: string): Promise<any> => {
  try {
    const readFileAsync = promisify(readFile);
    const fileString: string = (await readFileAsync(path, 'utf-8')) as string;
    if (fileString.length === 0) {
      throw new Error(`${path} is an empty file`);
    }
    const obj = JSON.parse(fileString);
    return obj;
  } catch (err) {
    throw err;
  }
};
