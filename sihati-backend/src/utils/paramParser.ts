export const parseIdParam = (idParam: string | string[]): number | null => {
  const idStr = Array.isArray(idParam) ? idParam[0] : idParam;
  const id = parseInt(idStr, 10);
  return isNaN(id) ? null : id;
};
