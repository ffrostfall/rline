export type Identity<T> = {
	success: true,
	value: T,
} | {
	success: false,
	err: string,
}

return (
	(
		function<T>(success: boolean, resultOrError: T & string): Identity<T>
			if success then
				return {
					success = true,
					value = resultOrError,
				}
			else
				return {
					success = false,
					err = resultOrError,
				}
			end
		end
	) :: any
) :: (<T>(success: true, value: T) -> Identity<T>) & (<T>(success: false, err: string) -> Identity<T>)
