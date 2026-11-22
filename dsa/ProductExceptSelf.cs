
namespace DSA;

public class ProductExceptSelf
{
    // 5.1 - Prefix and Suffix Arrays
    // Time Complexity: O(n)
    // Space Complexity: O(n) - prefix[] and suffix[]

    public static int[] SolveWithPrefixSuffix(int[] nums)
    {
        int n = nums.Length;

        int[] prefix = new int[n];
        int[] suffix = new int[n];
        int[] result = new int[n];

        prefix[0] = 1;

        for (int i = 1; i < n; i++)
        {
            prefix[i] = prefix[i - 1] * nums[i - 1];
        }

        suffix[n - 1] = 1;

        for (int i = n - 2; i >= 0; i--)
        {
            suffix[i] = suffix[i + 1] * nums[i + 1];
        }

        for (int i = 0; i < n; i++)
        {
            result[i] = prefix[i] * suffix[i];
        }

        return result;
    }

    // 5.2 - Optimized Prefix and Suffix
    // Time Complexity: O(n)
    // Space Complexity: O(1) extra space (output array excluded)

    public static int[] SolveOptimized(int[] nums)
    {
        int n = nums.Length;
        int[] result = new int[n];

        result[0] = 1;

        for (int i = 1; i < n; i++)
        {
            result[i] = result[i - 1] * nums[i - 1];
        }

        int suffix = 1;

        for (int i = n - 1; i >= 0; i--)
        {
            result[i] *= suffix;
            suffix *= nums[i];
        }

        return result;
    }
}
