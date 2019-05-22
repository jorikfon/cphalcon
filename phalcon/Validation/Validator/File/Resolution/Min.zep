
/**
 * This file is part of the Phalcon Framework.
 *
 * (c) Phalcon Team <team@phalconphp.com>
 *
 * For the full copyright and license information, please view the LICENSE.txt
 * file that was distributed with this source code.
 */

namespace Phalcon\Validation\Validator\File\Resolution;

use Phalcon\Messages\Message;
use Phalcon\Validation;
use Phalcon\Validation\Validator\File\FileAbstract;

/**
 * Phalcon\Validation\Validator\File\Resolution\Min
 *
 * Checks if a file has the rigth resolution
 *
 * <code>
 * use Phalcon\Validation;
 * use Phalcon\Validation\Validator\File\Resolution\Min;
 *
 * $validator = new Validation();
 *
 * $validator->add(
 *     "file",
 *     new Min(
 *         [
 *             "resolution" => "800x600",
 *             "message"    => "Min resolution of :field is :resolution",
 *             "included"   => true,
 *         ]
 *     )
 * );
 *
 * $validator->add(
 *     [
 *         "file",
 *         "anotherFile",
 *     ],
 *     new Min(
 *         [
 *             "resolution" => [
 *                 "file"        => "800x600",
 *                 "anotherFile" => "1024x768",
 *             ],
 *             "included" => [
 *                 "file"        => false,
 *                 "anotherFile" => true,
 *             ],
 *             "message" => [
 *                 "file"        => "Min resolution of file is 800x600",
 *                 "anotherFile" => "Min resolution of file is 1024x768",
 *             ],
 *         ]
 *     )
 * );
 * </code>
 */
class Min extends FileAbstract
{
    protected advice = "File :field can not have the minimum resolution of :resolution";

    /**
     * Executes the validation
     */
    public function validate(<Validation> validation, var field) -> bool
    {
        var code, height, label, minHeight, minWidth, resolution, resolutionArray,
            tmp, value, width, replacePairs, included = false, result;

        // Check file upload
        if (this->checkUpload(validation, field) === false) {
            return false;
        }

        let tmp = getimagesize(value["tmp_name"]),
            width = tmp[0],
            height = tmp[1],
            value = validation->getValue(field);

        let resolution = this->getOption("resolution");

        if typeof resolution == "array" {
            let resolution = resolution[field];
        }

        let resolutionArray = explode("x", resolution),
            minWidth = resolutionArray[0],
            minHeight = resolutionArray[1];

        let included = this->getOption("included");

        if typeof included == "array" {
            let included = (bool) included[field];
        } else {
            let included = (bool) included;
        }

        if (included) {
            let result = width <= minWidth || height <= minHeight;
        } else {
            let result = width < minWidth || height < minHeight;
        }

        if typeof resolution == "array" {
            let resolution = resolution[field];
        }

        if (result) {
            let replacePairs = [
                ":field"      : label,
                ":resolution" : resolution
            ];

            validation->appendMessage(
                new Message(
                    strtr(this->getAdvice(field), replacePairs),
                    field,
                    get_class(this),
                    code
                )
            );

            return false;
        }

        return true;
    }
}
